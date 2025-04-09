#!/bin/bash

set -e 
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
  export SUBSCRIPTION_ID=$(echo $SUBSCRIPTION_ID | tr -d '\r\n')
  export RESOURCE_GROUP=$(echo $RESOURCE_GROUP | tr -d '\r\n')
  export AKS_CLUSTER=$(echo $AKS_CLUSTER | tr -d '\r\n')
  export ACR_NAME=$(echo $ACR_NAME | tr -d '\r\n')
  export ACR_LOGIN=$(echo $ACR_LOGIN | tr -d '\r\n')
  export NAMESPACE=$(echo $NAMESPACE | tr -d '\r\n')


else
  echo ".env file not found. Exiting."
  exit 1
fi

# === Static config ===
APP_NAME="webapp"
DEPLOYMENT_FILE="deployment.yaml"
VERSION_TAG=$(date +%Y%m%d%H%M%S)
IMAGE_TAG="$ACR_NAME/$APP_NAME:$VERSION_TAG"

echo "Deploying $APP_NAME with tag $VERSION_TAG"

# === Login and get kubeconfig ===
echo "Logging into Azure..."
az account show > /dev/null 2>&1 || az login
az account set --subscription "$SUBSCRIPTION_ID"

echo "Connecting to ACR..."
az acr login -n $ACR_LOGIN
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER --overwrite-existing

# === Build & Push Docker image ===
echo "Building Docker image..."
docker build --platform=linux/amd64 -t $IMAGE_TAG .

echo "Pushing Docker image..."
docker push $IMAGE_TAG

# === Update image tag in deployment.yaml ===
echo "Updating image in $DEPLOYMENT_FILE..."
cp $DEPLOYMENT_FILE tmp_$DEPLOYMENT_FILE
sed -i.bak "s|image: .*|image: $IMAGE_TAG|" tmp_$DEPLOYMENT_FILE
