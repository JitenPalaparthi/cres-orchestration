variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed."
  type        = string
  default     = "global"
}
variable "postgres_db" {
  description = "Postgres DB name"
  default = "vehicle_master_bd"
}

variable "postgres_user" {
  description = "Postgres DB User"
  default = "postgres"
}

variable "postgres_password" {
  description = "Postgres DB Password"
  default = "postgres"
}

job "vehicleMaster-db" {
  region = var.region
  datacenters = var.datacenters
  type        = "service"
  group "db" {
    network {
      port "db" {
        to = 5432
      }
    }

    task "postgres" {
      driver = "docker"

      meta {
        service = "database"
      }
    service {
      name = "database"
      port = "db"
      provider="nomad"
    }
      config {
        image = "postgres"
        ports = ["db"]
      }
      resources {
        cpu    = 500
        memory = 500
      }
      env {
       
        POSTGRES_DB       = var.postgres_db
        POSTGRES_USER     = var.postgres_user
        POSTGRES_PASSWORD = var.postgres_password
      }
    }
  }
}