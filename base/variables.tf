variable "ssh_key" {
  description = "Provides custom public SSH key"
  type        = string
}

variable "project_name" {
  description = "name of the project"
  default     = "ghost"
}

variable "engineer_name" {
  description = "engineer's first name"
  default     = "artem"
}

variable "engineer_surname" {
  description = "engineer's last name"
  default     = "zaporozhskyi"
}

variable "region" {
  description = "aws region"
  default     = "use1"
}

variable "environment" {
  description = "environment"
  default     = "prod"
}