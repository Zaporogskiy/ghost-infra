variable "ssh_key" {
  description = "Provides custom public SSH key"
  type        = string
}

variable "engineer_name" {
  description = "engineer's first name"
  default     = "artem"
}

variable "engineer_surname" {
  description = "engineer's last name"
  default     = "zaporozhskyi"
}