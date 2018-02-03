#!/bin/bash

NAMESPACE=default
NAME=newapp-2
APPID=c2cac359-27f4-41d2-ae58-34adfc0ddf24
IMAGE=kdunetz/mendix-$NAME:1.0

createdbjs $NAME --user=postgres --password=4fjPLHgUDI --host=169.45.189.35 --port=30131

svn checkout https://teamserver.sprintr.com/$APPID/trunk --username "kdunetz@us.ibm.com" --password Sideout01! build 

docker build --build-arg BUILD_PATH=build -t $IMAGE .

docker push $IMAGE

IMAGE=${IMAGE//[\/]/\\\/}
kubectl create -f <(cat kubernetes/mendix-service.yml | sed "s/IMAGE/$IMAGE/g" | sed "s/NAME/$NAME/g") -n $NAMESPACE
kubectl create -f <(cat ingress.yml | sed "s/IMAGE/$IMAGE/g" | sed "s/NAME/$NAME/g")  -n $NAMESPACE
kubectl delete -f <(cat kubernetes/mendix-app-kad.yml | sed "s/IMAGE/$IMAGE/g" | sed "s/NAME/$NAME/g") -n $NAMESPACE
kubectl create -f <(cat kubernetes/mendix-app-kad.yml | sed "s/IMAGE/$IMAGE/g" | sed "s/NAME/$NAME/g") -n $NAMESPACE
