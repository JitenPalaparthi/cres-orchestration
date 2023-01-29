# cres-orchestration
cres project orchestration scripts

- Orchestration will be done using nomad

```nomad job run vehicleMaster.nomad``` 

-Run nomad client in dev mode
```sudo nomad agent -dev -bind=0.0.0.0 -network-interface=wlp59s0```


- more reads
    - https://discuss.hashicorp.com/t/i-dont-understand-networking-between-services/24470/3
    - https://developer.hashicorp.com/nomad/docs/faq#q-how-to-connect-to-my-host-network-when-using-docker-desktop-windows-and-macos

# keycloak

    - keycloak component automatically up and run when docker-compose up -d is called that is in the docker-compose directory.
    - a new realm is already create named "CRES"
    - a new client is already created under CRES realm.Client named "cres-app"
    - to access keycloak browse http://localhost:8080
    - username : root
    - password: oooo

Note: Do not puch changes to this repo unless discussed.