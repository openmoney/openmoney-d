#!/bin/bash

mkdir openmoney
cd openmoney
git clone https://github.com/jethro-swan/openmoney-api
git clone https://github.com/jethro-swan/openmoney-network
cp ../dockerbits/openmoney-api/* openmoney-api/
cp ../dockerbits/openmoney-network/* openmoney-network/
cp ../dockerbits/docker-compose.yml .
docker-compose up

