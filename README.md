# ECF DevOps – Projet InfoLine

## Présentation du projet

Ce projet a pour objectif de déployer une application web complète dans une infrastructure **cloud AWS** en utilisant des pratiques **DevOps**.

L’architecture déployée comprend :

* un **frontend Angular**
* une **API backend Spring Boot**
* un **cluster Kubernetes (Amazon EKS)**
* un déploiement automatisé avec **Docker**
* une **infrastructure définie avec Terraform**
* une fonction **AWS Lambda**
* un système de **collecte et visualisation des logs avec Filebeat, Elasticsearch et Kibana**

Le projet a été réalisé sur **Ubuntu WSL**.

---

# Architecture du projet

```
Utilisateur
     │
     ▼
Frontend Angular (Docker)
     │
     ▼
API Backend Spring Boot (Docker)
     │
     ▼
Cluster Kubernetes (Amazon EKS)
     │
 ┌───────────────┬───────────────┐
 ▼               ▼               ▼
Pods API      Pods Frontend   Filebeat
                                  │
                                  ▼
                           Elasticsearch
                                  │
                                  ▼
                                Kibana
                                  │
                                  ▼
                         Visualisation des logs
```

---

# Structure du repository

```
ecf-infoline-aws
│
├── terraform
│   └── main.tf
│
├── lambda
│   ├── lambda_function.py
│   └── response.json
│
├── springboot-api
│   ├── Dockerfile
│   ├── pom.xml
│   ├── k8s
│   ├── scripts
│   └── src
│
├── infoline-frontend
│   ├── Dockerfile
│   ├── package.json
│   ├── k8s
│   ├── scripts
│   └── src
│
└── filebeat-values.yaml
```

---

# Environnement de travail

Le projet a été réalisé sur :

* Windows 11
* **WSL Ubuntu**
* Docker
* kubectl
* Terraform
* AWS CLI

---

# Installation des outils

## Mise à jour du système

```bash
sudo apt update
sudo apt upgrade -y
```

---

## Installation Docker

```bash
sudo apt install docker.io -y
sudo usermod -aG docker $USER
```

Vérification :

```bash
docker --version
```

---

## Installation kubectl

```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

---

## Installation Terraform

```bash
sudo apt install terraform -y
```

Vérification :

```bash
terraform version
```

---

## Installation AWS CLI

```bash
sudo apt install awscli -y
```

Configuration :

```bash
aws configure
```

---

# Infrastructure AWS avec Terraform

L’infrastructure est définie dans :

```
terraform/main.tf
```

Terraform permet de créer automatiquement :

* VPC
* Subnets
* Internet Gateway
* Cluster **EKS**
* Node group

Initialisation Terraform :

```bash
terraform init
```

Vérification du plan :

```bash
terraform plan
```

Application de l’infrastructure :

```bash
terraform apply
```

---

# Backend Spring Boot

Le backend est développé en **Java Spring Boot**.

Fichier principal :

```
springboot-api/src/main/java/com/infoline/demo/HelloController.java
```

Exemple d’endpoint :

```java
@RestController
public class HelloController {

    @GetMapping("/hello")
    public String hello() {
        return "Hello Infoline";
    }

}
```

---

# Build du backend

Compilation Maven :

```bash
mvn clean package
```

---

# Dockerisation du backend

Dockerfile :

```dockerfile
FROM maven:3.8.7-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

---

# Build et push vers AWS ECR

Script utilisé :

```
springboot-api/scripts/build-test.sh
```

Commandes principales :

```bash
docker build -t infoline-springboot-api:1.0 .
docker tag infoline-springboot-api:1.0 <ECR_URL>
docker push <ECR_URL>
```

---

# Déploiement Kubernetes Backend

```
springboot-api/k8s/springboot-deployment.yaml
```

Déploiement :

```bash
kubectl apply -f k8s/springboot-deployment.yaml
kubectl apply -f k8s/springboot-service.yaml
```

---

# Frontend Angular

Le frontend est développé avec **Angular**.

Installation dépendances :

```bash
npm install
```

Build :

```bash
npm run build
```

---

# Dockerisation du frontend

Dockerfile :

```dockerfile
FROM node:20 AS build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/dist/infoline-frontend/browser /usr/share/nginx/html
EXPOSE 80
```

---

# Déploiement Kubernetes Frontend

```
infoline-frontend/k8s/frontend-deployment.yaml
```

Commandes :

```bash
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml
```

---

# Fonction AWS Lambda

Fonction simple utilisée pour tester le serverless.

Fichier :

```
lambda/lambda_function.py
```

Exemple :

```python
def lambda_handler(event, context):

    return {
        'statusCode': 200,
        'body': 'Lambda InfoLine OK'
    }
```

---

# Supervision avec ELK

Stack utilisée :

* Filebeat
* Elasticsearch
* Kibana

---

# Installation Elasticsearch et Kibana

Avec Helm :

```bash
helm repo add elastic https://helm.elastic.co
helm repo update
```

Installation Elasticsearch :

```bash
helm install elasticsearch elastic/elasticsearch
```

Installation Kibana :

```bash
helm install kibana elastic/kibana
```

---

# Installation Filebeat

Fichier de configuration :

```
filebeat-values.yaml
```

Installation :

```bash
helm install filebeat elastic/filebeat -f filebeat-values.yaml
```

---

# Visualisation des logs

Les logs Kubernetes sont collectés depuis :

```
/var/log/containers
```

Filebeat les envoie vers **Elasticsearch**.

Dans **Kibana**, les logs sont consultables via :

```
Discover
```

Recherches utilisées :

```
springboot-api
infoline-frontend
ERROR
```

---

# Vérification du cluster

Commande utilisée :

```bash
kubectl get pods
```

Exemple :

```
springboot-api
infoline-frontend
filebeat
elasticsearch
kibana
```

---

# Dépôt GitHub

Le code source du projet est disponible ici :

```
https://github.com/alaa-linux/ecf-infoline-aws
```

---

# Conclusion

Ce projet a permis de mettre en œuvre plusieurs concepts DevOps :

* Infrastructure as Code avec **Terraform**
* Conteneurisation avec **Docker**
* Orchestration avec **Kubernetes**
* Déploiement cloud avec **AWS**
* Monitoring et logs avec **ELK Stack**

Ces outils permettent d’automatiser et de fiabiliser le déploiement d’une application moderne dans le cloud.
