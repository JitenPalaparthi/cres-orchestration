job "databases" {
  datacenters = ["dc1"]
  type        = "service"
  group "database" {
    count = 1
    network {
      port "db" {
        to           = 5432
      }
    }
    service {
      name = "postgres-service"
      port = "db"
      provider="nomad"
    }

    task "postgres" {
      driver = "docker"
      config {
        image = "postgres"
        ports = ["db"]
      }
      resources {
        cpu    = 500
        memory = 500

      }
      env {
        POSTGRES_PASSWORD = "postgres"
        POSTGRES_DB       = "vehicle_master_bd"
        POSTGRES_USER     = "postgres"
      }
    }
  }
}