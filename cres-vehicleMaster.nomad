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
  default     = "vehicle_master_db"
}

variable "postgres_user" {
  description = "Postgres DB User"
  default     = "postgres"
}

variable "postgres_password" {
  description = "Postgres DB Password"
  default     = "postgres"
}

# Begin Job Spec
job "cres-vehicleMaster" {
  //type        = "service"
  region      = var.region
  datacenters = var.datacenters
  group "db" {
    network {
      port "db" {
        static = 5432
      }
    }

    task "postgres" {
      driver = "docker"

      meta {
        service = "database"
      }
      service {
        name     = "database"
        port     = "db"
        provider = "consul"
       
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
  group "vehicleMaster-api" {
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

    task "vehicleMaster-api" {
      driver = "docker"
      service {
        name     = "vehicleMaster-api"
        tags     = ["vehicleMaster", "RESTAPI"]
        port     = "api"
        provider = "consul"
      }
      template {
        data        = <<EOH
DB_CONN=host={{ range service "database" }}{{.Address}} port={{.Port}} {{ end }}user=${var.postgres_user} password=${var.postgres_password} dbname=${var.postgres_db} sslmode=disable
EOH
        destination = "local/env.txt"
        env         = true
      }
      env {
        // DB_CONN = "host=127.0.0.1 port=5432 user=postgres password=postgres dbname=vehicle_master_bd sslmode=disable"
        //DB_CONN = "host=${NOMAD_IP_postgres} port=${NOMAD_PORT_postgres} user=${var.postgres_user} password=${var.postgres_password} dbname=${var.postgres_db} sslmode=disable"
        PORT    = "50080"
      }
      config {
        image = "jpalaparthi/vehiclemaster:v0.0.6"
        ports = ["api"]
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 512 # 256MB
      }
    }
  }
}