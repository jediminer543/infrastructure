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
    ssl = bool
    annotations = map(string)
  }
  sensitive = true
  default = {
    enabled = false
    domain = "hedgedoc.example.com"
    ssl = false
    annotations = {
        "cert-manager.io/cluster-issuer" = "example cluster issuer"
    }
  }
  description = "Database to create by default"
}

