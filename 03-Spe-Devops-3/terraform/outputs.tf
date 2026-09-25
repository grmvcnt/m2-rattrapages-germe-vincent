output "application_url" {
  description = "Adresse publique de l application"
  value       = "http://${aws_lb.main.dns_name}"
}

output "ecr_repository_url" {
  description = "Depot ECR utilise par la pipeline"
  value       = aws_ecr_repository.app.repository_url
}

output "ecs_cluster_name" {
  description = "Nom du cluster ECS"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Nom du service ECS"
  value       = aws_ecs_service.app.name
}

output "task_definition_family" {
  description = "Famille de definition de tache mise a jour a chaque deploiement"
  value       = aws_ecs_task_definition.app.family
}

output "github_actions_role_arn" {
  description = "Role a renseigner dans le secret AWS_DEPLOY_ROLE_ARN"
  value       = aws_iam_role.github_actions.arn
}

output "log_group_name" {
  description = "Groupe de logs CloudWatch de l application"
  value       = aws_cloudwatch_log_group.app.name
}
