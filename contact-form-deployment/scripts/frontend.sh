#!/bin/bash
apt update -y
apt install docker.io -y
systemctl start docker
docker pull akshay405/contact-form-frontend:latest
docker run -d -p 3000:3000 akshay405/contact-form-frontend:latest

