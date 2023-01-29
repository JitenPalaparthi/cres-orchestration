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

variable "mysql_db" {
  description = "MySql DB name"
  default     = "vehicle_master_db"
}

variable "mysql_user" {
  description = "MySql DB User"
  default     = "postgres"
}
variable "mysql_root_user" {
  description = "MySql DB User"
  default     = "root"
}
variable "mysql_password" {
  description = "MySql DB Password"
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
        to = 3306
      }
    }

    task "mysql" {
      driver = "docker"

      meta {
        service = "database"
      }
      service {
        name     = "database"
        port     = "db"
        provider = "nomad"
       
      }
      config {
        image = "mysql"
        ports = ["db"]
      }
      resources {
        cpu    = 500
        memory = 500
      }
      env {
        MYSQL_DATABASE      = var.mysql_db
        MYSQL_USER          = var.mysql_user
        MYSQL_ROOT_PASSWORD = var.mysql_password
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
        provider = "nomad"
      }
      template {
        data        = <<EOH
DB_CONN="${var.mysql_root_user}:${var.mysql_password}@tcp({{ range nomadService "database" }}{{.Address}}:{{.Port}}){{ end }}/${var.mysql_db}?charset=utf8mb4&parseTime=True&loc=Local"
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
        image = "jpalaparthi/vehiclemaster:v0.0.7"
        ports = ["api"]
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 512 # 256MB
      }
    }
  }
}