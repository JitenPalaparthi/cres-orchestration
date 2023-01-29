#!/bin/bash

REALM="master"
PORT="8080"
HOST="localhost"

export TKN=$(curl -X POST "http://$HOST:$PORT/realms/$REALM/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d 'client_id=admin-cli' \
    -d 'client_secret=PFga3R4avabfK8o4nv82JZk1FS6mOGDe' \
    -d 'grant_type=client_credentials')

echo $TKN

curl --request POST "http://localhost:8080/admin/realms/master/users" --header "Authorization: Bearer $TKN" \

curl --location --request POST 'http://localhost:8080/admin/realms/CRES/users' \
--header 'Content-Type: application/json' \
--header "Authorization: Bearer $TKN" \
--data-raw '{
"firstName":"Jiten",
"lastName":"p",
"email":"test1@test.com",
"username":"jitenp",
"enabled":true
}'