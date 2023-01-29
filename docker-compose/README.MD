# Run application

    - Make sure docker-compose is ins
    talled in your machine

    - To run  
        
```docker-compose up -d```

    - To down 

```docker-compose down```

# To access application

```curl localhost:8080/ping``` 

# How to access pgadmin (UI for database)

- go browser , access http://localhost:8080

- enter username and password

    user=demo@cres.rent
    password=cres@123

- right click on server(left panel)->Register->server
- give a name in general(tab) Name: Vehicle Master DB
- click on second tab called connections
    - host name/address : postgresdb (give only this name)
    - port : 5432
    - maintainance database: vehicle_master_db
    - username : postgres
    - password : postgres
    - save it
- it connects to a database
- expand and see database objects (tables, functions etc..)

