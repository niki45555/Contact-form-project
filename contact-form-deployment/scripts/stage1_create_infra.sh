#!/bin/bash
cd terraform
terraform init
terraform apply -auto-approve
terraform output frontend_ip > ../terraform_outputs.txt
cd ..

