variable "namespace" {
  type = string
  default = "hedgedoc"
  description = "Kubernetes namespace for service"
}

variable "part_of" {
  type = string
  default = "hedgedoc"
  description = "Larger service component this is part of"
}

variable "db_username" {
  type = string
  default = "postgres"
  description = "Username for database"
}

variable "db_database" {
  type = string
  default = "postgres"
  description = "Database to use"
}

variable "db_hostname" {
  type = string
  description = "Database url to use"
}

variable "db_password" {
  type = string
  sensitive = true
  description = "Database to create by default"
}

variable "ingress" {
  type = {
    enabled = bool
    domain = string
  }
  sensitive = true
  description = "Database to create by default"
}

