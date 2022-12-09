job "vehicleMaster" {
  datacenters = ["dc1"]
  type        = "service"
  group "vehicleMaster" {
    count = 1
    network {
      port "api" {
        to = 50080
      }
    }
    service {
      name     = "vehicleMaster-api"
      tags     = ["vehicleMaster", "RESTAPI"]
      port     = "api"
      provider = "nomad"
    }
    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }
    ephemeral_disk {
      size = 300
    }
    task "vehicleMaster" {
      driver = "docker"

      template {
        data        = <<EOH
{{ range nomadService "postgres-service" }}
DB_CONN="host={{ .Address }} port={{ .Port }} user=postgres password=postgres dbname=vehicle_master_bd"
{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }

      env {
        PORT    = "50080"
      }
      config {
        image          = "jpalaparthi/vehiclemaster:v0.0.1"
        ports          = ["api"]
        auth_soft_fail = true
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 256 # 256MB
      }
    }
  }
}
