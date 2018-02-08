#!/bin/bash

NAMESPACE=default
NAME=production-app
APPID=bf58a52c-6f51-49cc-9208-b3cdad5bc499

IMAGE=kdunetz/mendix-$NAME:4.0

svn checkout https://teamserver.sprintr.com/$APPID/trunk --username "kdunetz@us.ibm.com" --password Sideout01! build 

docker build --build-arg BUILD_PATH=build -t $IMAGE .

docker push $IMAGE

kubectl patch statefulset mendix-$NAME-stateful -p '{"spec":{"updateStrategy":{"type":"RollingUpdate"}}}' -n default

#kubectl patch statefulset mendix-$NAME-stateful --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/image", "value":$IMAGE}]' -n default

SUBCOMMAND="[{\"op\": \"replace\", \"path\": \"/spec/template/spec/containers/0/image\", \"value\":\"$IMAGE\"}]"

kubectl patch statefulset mendix-$NAME-stateful --type='json' -p="$SUBCOMMAND" -n default

