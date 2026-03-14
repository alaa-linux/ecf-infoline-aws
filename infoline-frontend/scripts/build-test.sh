#!/bin/bash

echo "Build Angular..."
npm install

echo "Test / compilation Angular..."
ng build

echo "Build image Docker..."
docker build -t infoline-frontend:1.1 .

echo "Tag image ECR..."
docker tag infoline-frontend:1.1 377152274560.dkr.ecr.eu-west-3.amazonaws.com/infoline-frontend:1.1

echo "Push image ECR..."
docker push 377152274560.dkr.ecr.eu-west-3.amazonaws.com/infoline-frontend:1.1

echo "Déploiement Kubernetes..."
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml

echo "Terminé."
