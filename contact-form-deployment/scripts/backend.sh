#!/bin/bash
apt update -y
apt install docker.io -y
systemctl start docker
docker pull akshay405/backend:latest
docker run -d -p 5000:5000 akshay405/backend:latest

