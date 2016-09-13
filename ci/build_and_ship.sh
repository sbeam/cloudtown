#!/bin/bash

TAG=$1

docker build -t syxyz/cloudtown:$TAG .
docker push syxyz/cloudtown:$TAG
