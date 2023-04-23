#!/bin/bash
# Reset the docker image
docker rmi clank-dnas
# Pass in the server IP
docker build --rm --tag clank-dnas --build-arg serverip=${1} .