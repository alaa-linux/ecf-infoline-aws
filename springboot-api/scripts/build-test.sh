#!/bin/bash
set -e

echo "Compilation et tests Spring Boot..."
mvn clean test package

echo "Build Docker..."
docker build -t infoline-springboot-api:1.0 .

echo "Tag image ECR..."
docker tag infoline-springboot-api:1.0 377152274560.dkr.ecr.eu-west-3.amazonaws.com/infoline-springboot-api:1.0

echo "Push image ECR..."
docker push 377152274560.dkr.ecr.eu-west-3.amazonaws.com/infoline-springboot-api:1.0

echo "Déploiement Kubernetes..."
kubectl apply -f k8s/springboot-deployment.yaml
kubectl apply -f k8s/springboot-service.yaml

echo "Terminé."
