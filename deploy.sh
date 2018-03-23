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

for i in "$@"
do
case $i in
    --pg_ip=*)
    PG_IP="${i#*=}"
    ;;
    --pg_port=*)
    PG_PORT="${i#*=}"
    ;;
    --pg_user=*)
    PG_USER="${i#*=}"
    ;;
    --pg_password=*)
    PG_PASSWORD="${i#*=}"
    ;;
    --pg_database=*)
    PG_DATABASE="${i#*=}"
    ;;
    *)
            # unknown option
    ;;
esac
done
echo "PG_USER="$PG_USER
echo "PG_PASSWORD="$PG_PASSWORD
echo "PG_DATABASE="$PG_DATABASE
echo "PG_IP="$PG_IP
echo "PG_PORT="$PG_PORT

# NO BUILD HERE

#createdbjs $NAME --user=postgres --password=4fjPLHgUDI --host=169.45.189.35 --port=30131

#svn checkout https://teamserver.sprintr.com/$APPID/trunk --username "kdunetz@us.ibm.com" --password Sideout01! build 

#docker build --build-arg BUILD_PATH=build -t $IMAGE .

#docker push $IMAGE

IMAGE=${IMAGE//[\/]/\\\/}
kubectl create -f <(cat kubernetes/mendix-service.yml | sed "s/IMAGE/$IMAGE/g" | sed "s/NAME/$NAME/g") -n $NAMESPACE
kubectl create -f <(cat ingress.yml | sed "s/IMAGE/$IMAGE/g" | sed "s/NAME/$NAME/g")  -n $NAMESPACE
kubectl delete -f <(cat kubernetes/mendix-app-kad.yml | sed "s/IMAGE/$IMAGE/g" | sed "s/NAME/$NAME/g") -n $NAMESPACE
kubectl create -f <(cat kubernetes/mendix-app-kad.yml | sed "s/IMAGE/$IMAGE/g" | sed "s/NAME/$NAME/g" | sed "s/PG_USER/$PG_USER/g" | sed "s/PG_PASSWORD/$PG_PASSWORD/g" | sed "s/PG_DATABASE/$PG_DATABASE/g" | sed "s/PG_IP/$PG_IP/g" | sed "s/PG_IP/$PG_IP/g" | sed "s/PG_PORT/$PG_PORT/g") -n $NAMESPACE
