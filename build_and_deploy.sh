#!/bin/bash

#NAMESPACE=default
#NAME=icp-overview-app
#APPID=cf7d92fb-6ac5-4516-ba36-485ece2c3dac
#IMAGE=kdunetz/mendix-$NAME:1.0

if [ -z "$IMAGE" ]
then
   echo "Please set environment variables with . ./setenv.sh"
   exit
fi

if [[ $NAME = *"_"* ]]; then
  echo "$NAME variable cannot have underscores in them"
  exit
fi

if [[ $NAME = *"mendix"* ]]; then
  echo "$NAME variable should not have the name mendix in there"
  exit
fi



createdbjs $NAME --user=postgres --password=4fjPLHgUDI --host=169.45.189.35 --port=30131

svn checkout https://teamserver.sprintr.com/$APPID/trunk --username "kdunetz@us.ibm.com" --password Sideout01! build 

docker build --build-arg BUILD_PATH=build -t $IMAGE .

docker push $IMAGE

IMAGE=${IMAGE//[\/]/\\\/}
kubectl create -f <(cat kubernetes/mendix-service.yml | sed "s/IMAGE/$IMAGE/g" | sed "s/NAME/$NAME/g") -n $NAMESPACE
kubectl create -f <(cat ingress.yml | sed "s/IMAGE/$IMAGE/g" | sed "s/NAME/$NAME/g")  -n $NAMESPACE
kubectl delete -f <(cat kubernetes/mendix-app-kad.yml | sed "s/IMAGE/$IMAGE/g" | sed "s/NAME/$NAME/g") -n $NAMESPACE
kubectl create -f <(cat kubernetes/mendix-app-kad.yml | sed "s/IMAGE/$IMAGE/g" | sed "s/NAME/$NAME/g") -n $NAMESPACE
