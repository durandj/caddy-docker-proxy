#!/bin/bash

CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -o artifacts/binaries/linux/amd64/caddy

docker network create caddy -d overlay --attachable

CADDY_REPLICAS=0 EXTERNAL_NETWORK=true docker stack deploy -c examples/example.yaml caddy-test

docker run --rm -it \
    -p 80:80 \
    -p 443:443 \
    -p 2019:2019 \
    --network caddy \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $PWD/artifacts/binaries/linux/amd64/caddy:/caddy \
    alpine:3.10 /caddy docker-proxy

docker stack rm caddy-test

docker network rm caddy
