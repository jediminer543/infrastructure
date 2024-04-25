variable "namespace" {
  type = string
  default = "postgresql"
  description = "Kubernetes namespace for service"
}

variable "part_of" {
  type = string
  default = ""
  description = "Larger service component this is part of"
}

variable "username" {
  type = string
  default = "postgres"
  description = "Username to create as root"
}

variable "database" {
  type = string
  default = "postgres"
  description = "Database to create by default"
}