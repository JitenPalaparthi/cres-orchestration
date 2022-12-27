job "artifact" {
  datacenters = ["dc1"]
  type        = "service"
  priority    = 100

  group "artifactory" {
    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }
    ephemeral_disk {
      migrate = false
      size    = "1024" #MB
      sticky  = true
    }

    task "pgsql" {
      driver = "docker"
      config {
        image = "postgres:9.6.11"
        port_map {
          pgsql-port = 5432
        }
        env {
          POSTGRES_DB       = artifactory
          POSTGRES_USER     = artifactory
          POSTGRES_PASSWORD = password
        }
        ulimit {
          # ensure elastic search can create enough open file handles
          nofile = "65536"

          # ensure elastic search can create enough threads
          nproc = "65535"
        }
        volumes = [
          "/data/postgres/data:/var/lib/postgresql/data",
          "/etc/localtime:/etc/localtime:ro"
        ]
      }
      resources {
        cpu    = 100
        memory = 512
        network {
          mbits = 10
          port "postgresConn" { static = 5432 }
        }
      }
      service {
        name = "postgres"
        port = "postgresConn"
        provider="nomad"
        check {
          name     = "postgresql_check"
          type     = "tcp"
          interval = "60s"
          timeout  = "5s"
        }
      }
    }

    task "artifact" {
      driver = "docker"
      config {
        image = "your-artifact-image"
        port_map {
          external-port = 2222
          arti-port     = 8081
        }
        volumes = [
          "local/db-config.conf:$ARTIFACTORY_HOME/etc/db.properties ",
          "/data/artifact/data:/var/opt/jfrog/artifactory",
          "/etc/localtime:/etc/localtime"
        ]
        env {
          JF_ROUTER_ENTRYPOINTS_EXTERNALPORT = JF_ROUTER_ENTRYPOINTS_EXTERNALPORT
        }
      }
      template {
        destination = "local/db-config.conf"
        data        = <<EOH
type=postgresql
driver=org.postgresql.Driver
url=jdbc:postgresql://{{ range nomadService "postgres" }}{{ .Address }}:5432{{ end }}/artifactory?ssl=true&sslfactory=org.postgresql.ssl.jdbc4.LibPQFactory&sslmode=verify-full
EOH
      }
      resources {
        cpu    = 100
        memory = 512
        network {
          mbits = 10
          port "external" { static = 2222 }
          port "arti" { static = 8081 }
        }
      }
      service {
        name = "artifact"
        port = "arti"
        provider="nomad"
        check {
          name     = "artifact_check"
          type     = "tcp"
          interval = "60s"
          timeout  = "5s"
        }
      }
    }
  }
}