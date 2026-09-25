variable "project_name" {
  description = "Prefixe applique au nom des ressources"
  type        = string
  default     = "rattrapage-devops3"
}

variable "aws_region" {
  description = "Region de deploiement"
  type        = string
  default     = "eu-west-3"
}

variable "github_repository" {
  description = "Depot autorise a deployer, au format owner/repo"
  type        = string
}

variable "github_branch" {
  description = "Branche autorisee a assumer le role de deploiement"
  type        = string
  default     = "main"
}

variable "container_port" {
  description = "Port expose par le conteneur"
  type        = number
  default     = 3000
}

variable "task_cpu" {
  description = "Unites de CPU allouees a la tache Fargate"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memoire en Mio allouee a la tache Fargate"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Nombre de taches executees par le service"
  type        = number
  default     = 1
}

variable "image_tag" {
  description = "Tag utilise par la definition de tache initiale"
  type        = string
  default     = "latest"
}

variable "log_retention_days" {
  description = "Duree de retention des logs applicatifs"
  type        = number
  default     = 7
}

variable "alert_email" {
  description = "Destinataire des alertes CloudWatch, vide pour ne pas creer d abonnement"
  type        = string
  default     = ""
}
