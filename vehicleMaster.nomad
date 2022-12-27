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
job "vehicleMaster" {
  datacenters = var.datacenters
  region = var.region
  type        = "service"
  group "vehicleMaster" {
    count = 1
    network {
      port "api" {
        to = 50080
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }
  
    task "vehicleMaster-container" {
      driver = "docker"
      
      service {
      name     = "vehicleMaster-api"
      tags     = ["vehicleMaster", "RESTAPI"]
      port     = "api"        
      provider = "nomad"
    }
   template {
        data        = <<EOH
{{ range nomadService "database" }}
DB_CONN="host=192.168.1.9 port={{ .Port }} user=${var.postgres_user} password=${var.postgres_password} dbname=${var.postgres_db} sslmode=disable"
{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }
      env {
        // DB_CONN = "host=127.0.0.1 port=5432 user=postgres password=postgres dbname=vehicle_master_bd sslmode=disable"
        //DB_CONN = "host=${NOMAD_IP_postgres-service} port=${NOMAD_PORT_db} user=${var.postgres_user} password=${var.postgres_password} dbname=${var.postgres_db} sslmode=disable"
        PORT = "50080"
      } 
      config {
        image          = "jpalaparthi/vehiclemaster:v0.0.3"
        ports          = ["api"]
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 512 # 256MB
      }
    }
  }
}
