# 03 – Spé DevOps 3 – AWS

Rattrapage sur le cours de Spé DevOps 3.
Application web conteneurisée déployée sur AWS ECS Fargate, infrastructure créée avec Terraform, déploiement automatisé par GitHub Actions.
L'application est volontairement minimale : un front React qui affiche un message récupéré auprès de son API.

## Contenu

- `backend/` : API Express, routes `/health` et `/api/message`, sert aussi le front compilé en production
- `frontend/` : interface React (Vite, Tailwind) qui affiche le message du backend ou l'erreur
- `Dockerfile` : build du front puis runtime Node
- `docker-compose.yml` : lancement local de l'image
- `terraform/` : infrastructure AWS (réseau, ECR, ECS, ALB, IAM, CloudWatch)
- `.github/workflows/deploy.yml` : build de l'image, publication sur ECR, déploiement sur ECS
- `.github/workflows/terraform.yml` : `fmt` et `validate` sur les pull requests

## Lancement local

Avec Docker, ce qui reproduit exactement l'image déployée :

```powershell
cd 03-Spe-Devops-3
docker compose up --build
```

## Déploiement

Prérequis : Docker, Terraform et l'AWS CLI configurée (`aws configure`) sur un compte autorisé à créer du réseau, de l'ECR, de l'ECS, de l'IAM et du CloudWatch.

1. Renseigner les variables Terraform.

```powershell
cd 03-Spe-Devops-3/terraform
copy terraform.tfvars.example terraform.tfvars
```

Mettre `github_repository` à la valeur `owner/repo` de son propre dépôt, et `alert_email` à son adresse (ou la laisser vide pour ne pas créer d'abonnement SNS).

2. Créer l'infrastructure.

```powershell
terraform init
terraform apply
```

3. Publier une première image, le dépôt ECR étant vide et le service ECS ne pouvant pas démarrer sans elle.

```powershell
$ecr = terraform output -raw ecr_repository_url
cd ..
aws ecr get-login-password --region eu-west-3 | docker login --username AWS --password-stdin $ecr.Split("/")[0]
docker build --platform linux/amd64 -t "${ecr}:latest" .
docker push "${ecr}:latest"
aws ecs update-service --cluster rattrapage-devops3 --service rattrapage-devops3 --force-new-deployment
```

4. Activer la pipeline en créant le secret `AWS_DEPLOY_ROLE_ARN` dans *Settings > Secrets and variables > Actions* du dépôt GitHub, avec la valeur renvoyée par :

```powershell
cd terraform
terraform output -raw github_actions_role_arn
```

5. Vérifier le résultat sur l'adresse renvoyée par `terraform output -raw application_url`.

Les déploiements suivants sont automatiques : chaque push sur `main` déclenche le build, la publication sur ECR et la mise à jour du service.

## Destruction

```powershell
cd terraform
terraform destroy
```

Le dépôt ECR est déclaré en `force_delete`, les images sont donc supprimées avec le reste et aucune ressource ne survit à la commande. Le groupe de logs et les alarmes sont également détruits.

## Architecture

Le schéma se trouve ici : ./Schema architecture.drawio.png

## CI/CD

Le workflow `deploy.yml` se déclenche sur un push vers `main`. Il s'authentifie sur AWS par OIDC, construit l'image, la publie sur ECR avec deux tags (le SHA du commit et `latest`), enregistre une nouvelle révision de la définition de tâche pointant sur le tag de commit, puis met à jour le service et attend sa stabilisation.

Aucun secret AWS n'est stocké dans le dépôt. GitHub présente un jeton OIDC, et la relation de confiance du rôle IAM n'accepte que ce dépôt et que la branche `main`. Le seul élément configuré dans GitHub est l'ARN du rôle, qui n'est pas un secret exploitable seul.

Le service ECS déclare `ignore_changes` sur sa définition de tâche pour que Terraform ne réécrase pas la révision déployée par la pipeline. Un `deployment_circuit_breaker` annule automatiquement le déploiement et restaure la version précédente si la nouvelle tâche ne devient jamais saine.

## Monitoring

Les logs du conteneur sont envoyés vers le groupe CloudWatch `/ecs/rattrapage-devops3` par le driver `awslogs`, avec une rétention de sept jours.

```powershell
aws logs tail /ecs/rattrapage-devops3 --since 15m --follow
```

Trois alarmes publient sur un topic SNS, auquel une adresse e-mail peut être abonnée :

- `cibles-indisponibles` : plus aucune tâche saine derrière le load balancer, c'est l'alarme de disponibilité principale
- `erreurs-5xx` : plus de cinq erreurs serveur sur cinq minutes
- `cpu-eleve` : CPU au-dessus de 80 % sur deux périodes consécutives

## Choix techniques

Une seule image pour le front et le back. Le `Dockerfile` compile le front dans une première étape, puis ne conserve que le runtime Node, les dépendances de production et les fichiers statiques. L'image finale fait environ 170 Mo, tourne avec l'utilisateur `node` et non root, et déclare un `HEALTHCHECK` sur `/health`.

Des politiques IAM écrites à la main plutôt que les politiques managées d'AWS. Le rôle d'exécution ECS ne peut tirer que ce dépôt ECR et écrire que dans ce groupe de logs, là où `AmazonECSTaskExecutionRolePolicy` autorise `*`. Le rôle de la tâche n'a aucune permission, puisque l'application n'appelle aucun service AWS. Le rôle de la pipeline est limité aux actions de publication et de mise à jour du service, et son `iam:PassRole` est restreint aux deux rôles ECS.

Le state Terraform est conservé en local. C'est acceptable pour un projet individuel, mais c'est une limite assumée, détaillée plus bas.

## Risques et améliorations

Sécurité. Le trafic circule en HTTP, sans TLS, faute de nom de domaine et de certificat. Les tâches sont dans des sous-réseaux publics, choix fait pour le coût. L'utilisateur IAM qui exécute Terraform dispose de droits administrateur, et sa clé d'accès est une clé longue durée stockée sur le poste. En production, il faudrait un certificat ACM avec redirection systématique vers HTTPS et un domaine Route 53, des sous-réseaux privés avec des points de terminaison VPC vers ECR et CloudWatch, un accès humain fédéré par IAM Identity Center plutôt que des clés, et un rôle de déploiement dédié à permissions réduites.

Disponibilité. Une seule tâche tourne, sur une seule zone de disponibilité à un instant donné : si elle tombe, le service est interrompu le temps qu'ECS en redémarre une, soit une trentaine de secondes. Il n'y a pas d'autoscaling, et tout est dans une seule région. En production, il faudrait au minimum deux tâches réparties sur les deux zones, une politique d'autoscaling sur le CPU ou le nombre de requêtes par cible, et un suivi du budget d'erreur.

Enfin, le state Terraform local n'est ni chiffré, ni sauvegardé, ni verrouillé, ce qui interdit tout travail à plusieurs et expose à une perte de suivi de l'infrastructure. Un backend S3 chiffré avec verrouillage serait le premier changement à faire pour un usage réel.

## Vidéo

Lien YouTube (non répertorié) :

## Recherches web

- Documentation AWS : ECS sur Fargate, ECR, ALB, OIDC pour GitHub Actions
- Registre Terraform : provider AWS
- Actions officielles `aws-actions` pour la connexion à ECR et le déploiement ECS
