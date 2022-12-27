# cres-orchestration
cres project orchestration scripts

- Orchestration will be done using nomad

```nomad job run vehicleMaster.nomad``` 

-Run nomad client in dev mode
```sudo nomad agent -dev -bind=0.0.0.0 -network-interface=wlp59s0```


- more reads
    - https://discuss.hashicorp.com/t/i-dont-understand-networking-between-services/24470/3
    - https://developer.hashicorp.com/nomad/docs/faq#q-how-to-connect-to-my-host-network-when-using-docker-desktop-windows-and-macos
