#!/bin/bash
IP=$(terraform -chdir=terraform output -raw frontend_ip)
echo "Frontend IP: $IP"
curl http://$IP:3000

