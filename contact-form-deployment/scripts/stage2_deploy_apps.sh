#!/bin/bash

echo "=== Stage 2: Deploying Apps ==="
cd terraform

# Re-run apply to ensure scripts are executed
terraform apply -auto-approve

cd ..
echo "✅ Containers deployed on EC2 via terraform provisioners."

