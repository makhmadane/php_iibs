# Guide de Migration Docker vers Kubernetes

Ce guide vous accompagne dans la transformation de votre application Docker Compose vers Kubernetes avec des explications détaillées pour apprendre les concepts au fur et à mesure.

## Table des matières

1. [Architecture de l'application](#architecture-de-lapplication)
2. [Différences Docker vs Kubernetes](#différences-docker-vs-kubernetes)
3. [Concepts Kubernetes expliqués](#concepts-kubernetes-expliqués)
4. [Prérequis](#prérequis)
5. [Installation et déploiement](#installation-et-déploiement)
6. [Commandes utiles](#commandes-utiles)
7. [Dépannage](#dépannage)
8. [Aller plus loin](#aller-plus-loin)

---

## Architecture de l'application

### Architecture Docker Compose (avant)

```yaml
nginx-iibs2 (port 80)
   ↓
php-iibs2 (port 9000)
   ↓
mysql-iibs2 (port 3306)
```

- **nginx-iibs2** : Serveur web Nginx
- **php-iibs2** : PHP-FPM 8.2 avec extensions MySQL
- **mysql-iibs2** : Base de données MySQL 8
- Tous connectés via un réseau Docker : `iibs-network`
- Volume persistant : `mysql_data` pour MySQL

### Architecture Kubernetes (après)

```
Internet
   ↓
Service Nginx (NodePort 30080)
   ↓
Pods Nginx (×2 réplicas)
   ↓
Service PHP (ClusterIP)
   ↓
Pods PHP-FPM (×2 réplicas)
   ↓
Service MySQL (ClusterIP)
   ↓
Pod MySQL (×1 réplica)
   ↓
PersistentVolumeClaim (1Gi)
```

---

## Différences Docker vs Kubernetes

| Aspect | Docker Compose | Kubernetes |
|--------|----------------|------------|
| **Orchestration** | Machine unique | Cluster de machines |
| **Scalabilité** | Manuelle | Automatique (HPA) |
| **Haute disponibilité** | Limitée | Native |
| **Service Discovery** | Nom du conteneur | Service DNS |
| **Configuration** | 1 fichier YAML | Multiples ressources YAML |
| **Volumes** | Volumes Docker | PV/PVC abstraction |
| **Réseau** | Bridge/Host | CNI plugins |
| **Secrets** | Variables env en clair | Secrets encodés |
| **Load Balancing** | Round-robin simple | Advanced (Services) |
| **Rolling Updates** | Non | Oui (Deployments) |
| **Self-healing** | Restart on failure | Auto-restart + rescheduling |

---

## Concepts Kubernetes expliqués

### 1. Namespace

**Analogie** : Un "dossier" virtuel pour organiser vos ressources.

**Pourquoi ?**
- Isoler différents projets ou environnements (dev, staging, prod)
- Gérer les permissions par namespace
- Éviter les conflits de noms

**Fichier** : `00-namespace.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: php-iibs
```

### 2. Secret

**Analogie** : Un coffre-fort pour stocker des mots de passe.

**Différence avec Docker** :
- Docker : Mots de passe en clair dans `docker-compose.yml`
- Kubernetes : Valeurs encodées en base64, chiffrables au repos

**Fichier** : `01-mysql-secret.yaml`

**Bonnes pratiques** :
- Ne jamais commiter les Secrets dans Git
- Utiliser des outils comme Sealed Secrets ou External Secrets Operator
- En production, utiliser HashiCorp Vault ou cloud secrets managers

### 3. ConfigMap

**Analogie** : Un fichier de configuration partagé.

**Différence avec Docker** :
- Docker : `COPY config.conf` dans le Dockerfile → Rebuild pour changer
- Kubernetes : ConfigMap → Changement sans rebuild

**Fichier** : `02-nginx-configmap.yaml`

**Avantages** :
- Séparer la configuration du code
- Même image Docker pour dev/staging/prod
- Changements rapides sans rebuild

### 4. PersistentVolumeClaim (PVC)

**Analogie** : Une "réservation" de stockage.

**Concepts** :
- **PersistentVolume (PV)** : Le disque physique (créé par l'admin)
- **PersistentVolumeClaim (PVC)** : La demande de stockage (créée par vous)
- **StorageClass** : Le "type" de stockage (SSD, HDD, NFS, etc.)

**Fichier** : `03-mysql-pvc.yaml`

**Access Modes** :
- **ReadWriteOnce (RWO)** : 1 seul nœud en lecture/écriture (MySQL)
- **ReadOnlyMany (ROX)** : Plusieurs nœuds en lecture seule
- **ReadWriteMany (RWX)** : Plusieurs nœuds en lecture/écriture (NFS)

### 5. Deployment

**Analogie** : Un "gestionnaire" qui garantit que X pods identiques tournent.

**Hiérarchie** :
```
Deployment
   ↓
ReplicaSet (gère les réplicas)
   ↓
Pods (conteneurs en cours d'exécution)
```

**Différence avec Docker** :
- Docker : Si le conteneur crash, il ne redémarre pas automatiquement
- Kubernetes : Redémarrage automatique, scaling, rolling updates

**Fichiers** : `04-mysql-deployment.yaml`, `05-php-deployment.yaml`, `06-nginx-deployment.yaml`

**Stratégies de mise à jour** :
- **RollingUpdate** (défaut) : Mise à jour progressive sans interruption
- **Recreate** : Supprime tous les pods puis recrée (downtime)

### 6. Service

**Analogie** : Un "load balancer interne" avec un DNS fixe.

**Problème résolu** :
- Les Pods ont des IPs dynamiques qui changent
- Comment Nginx trouve-t-il PHP-FPM ?
- Solution : Le Service donne un nom DNS stable

**Types de Service** :

| Type | Usage | Accès |
|------|-------|-------|
| **ClusterIP** | Communication interne | `service-name.namespace.svc.cluster.local` |
| **NodePort** | Exposition externe (port 30000-32767) | `http://<node-ip>:<node-port>` |
| **LoadBalancer** | Load balancer cloud (AWS, GCP, Azure) | `http://<lb-ip>` |
| **ExternalName** | Alias vers un DNS externe | - |

**Dans notre application** :
- `mysql-service` : ClusterIP (interne uniquement)
- `php-service` : ClusterIP (interne uniquement)
- `nginx-service` : NodePort (accessible depuis l'extérieur)

### 7. Pod

**Analogie** : L'unité la plus petite dans Kubernetes, comme un "conteneur+".

**Caractéristiques** :
- Contient 1 ou plusieurs conteneurs
- Partage le réseau (localhost entre conteneurs)
- Partage le stockage (volumes)
- IP éphémère (change à chaque redémarrage)

**Lifecycle** :
1. **Pending** : Kubernetes cherche un nœud pour le Pod
2. **Running** : Le Pod est en cours d'exécution
3. **Succeeded** : Le Pod a terminé avec succès (jobs)
4. **Failed** : Le Pod a échoué
5. **Unknown** : État inconnu (problème de communication)

### 8. Probes (Vérifications de santé)

**livenessProbe** : "Est-ce que le conteneur est vivant ?"
- Si échec → Kubernetes **redémarre** le conteneur
- Exemple : Ping MySQL toutes les 10s

**readinessProbe** : "Est-ce que le conteneur est prêt à recevoir du trafic ?"
- Si échec → Kubernetes **retire** le Pod du Service (pas de trafic)
- Exemple : Vérifier que Nginx répond HTTP 200

**startupProbe** : "Est-ce que l'application a démarré ?"
- Utile pour les applications qui mettent du temps à démarrer
- Si échec → Pas encore de liveness/readiness checks

---

## Prérequis

### 1. Installer kubectl

**Windows** :
```powershell
choco install kubernetes-cli
# Ou télécharger depuis : https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
```

**macOS** :
```bash
brew install kubectl
```

**Linux** :
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

**Vérification** :
```bash
kubectl version --client
```

### 2. Installer un cluster Kubernetes local

#### Option 1 : Minikube (Recommandé pour apprendre)

**Pourquoi Minikube ?**
- Facile à installer
- Cluster Kubernetes local complet
- Parfait pour le développement

**Installation** :

**Windows** :
```powershell
choco install minikube
```

**macOS** :
```bash
brew install minikube
```

**Linux** :
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

**Démarrer Minikube** :
```bash
minikube start
```

**Vérifier** :
```bash
kubectl cluster-info
kubectl get nodes
```

#### Option 2 : Docker Desktop (Windows/macOS)

1. Installer Docker Desktop
2. Settings → Kubernetes → Enable Kubernetes
3. Apply & Restart

#### Option 3 : Kind (Kubernetes in Docker)

```bash
# Installation
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Créer un cluster
kind create cluster --name php-iibs
```

#### Option 4 : K3s (Lightweight Kubernetes)

```bash
curl -sfL https://get.k3s.io | sh -
```

---

## Installation et déploiement

### Méthode 1 : Déploiement avec Kustomize (Recommandé)

**Avantage** : Une seule commande déploie tout.

```bash
# Se placer dans le répertoire du projet
cd C:\Users\m.lo\Downloads\php_iibs

# Déployer toute l'application
kubectl apply -k k8s/

# Vérifier le déploiement
kubectl get all -n php-iibs
```

### Méthode 2 : Déploiement manuel (pour comprendre l'ordre)

```bash
# 1. Créer le namespace
kubectl apply -f k8s/00-namespace.yaml

# 2. Créer les Secrets et ConfigMaps
kubectl apply -f k8s/01-mysql-secret.yaml
kubectl apply -f k8s/02-nginx-configmap.yaml

# 3. Créer le PersistentVolumeClaim
kubectl apply -f k8s/03-mysql-pvc.yaml

# 4. Déployer MySQL
kubectl apply -f k8s/04-mysql-deployment.yaml

# 5. Déployer PHP-FPM
kubectl apply -f k8s/05-php-deployment.yaml

# 6. Déployer Nginx
kubectl apply -f k8s/06-nginx-deployment.yaml
```

### Vérifier le déploiement

```bash
# Voir toutes les ressources
kubectl get all -n php-iibs

# Voir les Pods
kubectl get pods -n php-iibs

# Voir les Services
kubectl get services -n php-iibs

# Voir les PVC
kubectl get pvc -n php-iibs

# Détails d'un Pod (si un Pod a un problème)
kubectl describe pod <nom-du-pod> -n php-iibs

# Logs d'un Pod
kubectl logs <nom-du-pod> -n php-iibs

# Logs en temps réel
kubectl logs -f <nom-du-pod> -n php-iibs
```

### Accéder à l'application

#### Avec Minikube :

```bash
# Ouvrir automatiquement dans le navigateur
minikube service nginx-service -n php-iibs

# Ou obtenir l'URL
minikube service nginx-service -n php-iibs --url
```

#### Avec Docker Desktop ou Kind :

```bash
# L'application sera accessible sur :
http://localhost:30080
```

#### Avec un cluster réel :

```bash
# Obtenir l'IP d'un nœud
kubectl get nodes -o wide

# Accéder via :
http://<node-ip>:30080
```

---

## Commandes utiles

### Gestion des ressources

```bash
# Lister toutes les ressources dans un namespace
kubectl get all -n php-iibs

# Lister les namespaces
kubectl get namespaces

# Lister les Pods
kubectl get pods -n php-iibs
kubectl get pods -n php-iibs -o wide  # Avec plus d'infos (IP, nœud, etc.)

# Lister les Deployments
kubectl get deployments -n php-iibs

# Lister les Services
kubectl get services -n php-iibs

# Lister les PVC
kubectl get pvc -n php-iibs

# Lister les ConfigMaps
kubectl get configmaps -n php-iibs

# Lister les Secrets
kubectl get secrets -n php-iibs
```

### Inspecter les ressources

```bash
# Détails d'un Pod
kubectl describe pod <nom-du-pod> -n php-iibs

# Détails d'un Service
kubectl describe service nginx-service -n php-iibs

# Détails d'un Deployment
kubectl describe deployment nginx-deployment -n php-iibs

# Logs d'un Pod
kubectl logs <nom-du-pod> -n php-iibs

# Logs en temps réel
kubectl logs -f <nom-du-pod> -n php-iibs

# Logs d'un conteneur spécifique (si plusieurs conteneurs dans le Pod)
kubectl logs <nom-du-pod> -c <nom-du-conteneur> -n php-iibs

# Exécuter une commande dans un Pod
kubectl exec -it <nom-du-pod> -n php-iibs -- /bin/bash
kubectl exec -it <nom-du-pod> -n php-iibs -- php -v
```

### Scaling (augmenter/diminuer les réplicas)

```bash
# Scaler le Deployment Nginx à 3 réplicas
kubectl scale deployment nginx-deployment --replicas=3 -n php-iibs

# Scaler le Deployment PHP à 5 réplicas
kubectl scale deployment php-deployment --replicas=5 -n php-iibs

# Vérifier
kubectl get pods -n php-iibs
```

### Mises à jour

```bash
# Mettre à jour l'image d'un Deployment
kubectl set image deployment/nginx-deployment nginx=nginx:1.25-alpine -n php-iibs

# Voir l'historique des rollouts
kubectl rollout history deployment/nginx-deployment -n php-iibs

# Annuler un rollout (rollback)
kubectl rollout undo deployment/nginx-deployment -n php-iibs

# Rollback vers une version spécifique
kubectl rollout undo deployment/nginx-deployment --to-revision=2 -n php-iibs

# Voir le statut d'un rollout
kubectl rollout status deployment/nginx-deployment -n php-iibs
```

### Éditer des ressources

```bash
# Éditer un Deployment
kubectl edit deployment nginx-deployment -n php-iibs

# Éditer un Service
kubectl edit service nginx-service -n php-iibs

# Éditer un ConfigMap
kubectl edit configmap nginx-config -n php-iibs
```

### Port-forwarding (pour le debugging)

```bash
# Forwarder un port local vers un Pod
kubectl port-forward pod/<nom-du-pod> 8080:80 -n php-iibs

# Forwarder un port local vers un Service
kubectl port-forward service/nginx-service 8080:80 -n php-iibs

# Accéder via : http://localhost:8080
```

### Supprimer des ressources

```bash
# Supprimer tout le namespace (supprime toutes les ressources)
kubectl delete namespace php-iibs

# Supprimer un Pod spécifique
kubectl delete pod <nom-du-pod> -n php-iibs

# Supprimer un Deployment
kubectl delete deployment nginx-deployment -n php-iibs

# Supprimer toutes les ressources avec Kustomize
kubectl delete -k k8s/

# Supprimer toutes les ressources d'un type
kubectl delete deployments --all -n php-iibs
kubectl delete services --all -n php-iibs
```

### Debugging

```bash
# Voir les événements (très utile pour déboguer)
kubectl get events -n php-iibs
kubectl get events -n php-iibs --sort-by='.lastTimestamp'

# Voir les ressources système (CPU, RAM)
kubectl top nodes
kubectl top pods -n php-iibs

# Voir la configuration d'un Pod en YAML
kubectl get pod <nom-du-pod> -n php-iibs -o yaml

# Copier un fichier depuis/vers un Pod
kubectl cp <nom-du-pod>:/path/to/file /local/path -n php-iibs
kubectl cp /local/file <nom-du-pod>:/path/to/file -n php-iibs

# Tester la connectivité réseau
kubectl run -it --rm debug --image=busybox --restart=Never -n php-iibs -- sh
# Dans le shell :
# wget -O- http://mysql-service:3306
# nslookup mysql-service
```

---

## Dépannage

### Problème : Les Pods ne démarrent pas

**Symptôme** :
```bash
kubectl get pods -n php-iibs
NAME                                READY   STATUS    RESTARTS   AGE
mysql-deployment-xxxxx              0/1     Pending   0          5m
```

**Solutions** :

1. **Vérifier les événements** :
```bash
kubectl describe pod mysql-deployment-xxxxx -n php-iibs
```

2. **Problèmes courants** :
   - **ImagePullBackOff** : L'image Docker n'existe pas ou est privée
     - Solution : Vérifier le nom de l'image, créer un imagePullSecret
   - **Insufficient CPU/Memory** : Pas assez de ressources sur le nœud
     - Solution : Réduire les `resources.requests` ou ajouter des nœuds
   - **PVC Pending** : Le PVC ne trouve pas de PV disponible
     - Solution : Créer un PV ou utiliser une StorageClass qui provisionne automatiquement

### Problème : Le Service Nginx n'est pas accessible

**Symptôme** :
```
http://localhost:30080 ne répond pas
```

**Solutions** :

1. **Vérifier que les Pods tournent** :
```bash
kubectl get pods -n php-iibs
```

2. **Vérifier le Service** :
```bash
kubectl get service nginx-service -n php-iibs
```

3. **Tester avec port-forward** :
```bash
kubectl port-forward service/nginx-service 8080:80 -n php-iibs
# Accéder via http://localhost:8080
```

4. **Vérifier les logs Nginx** :
```bash
kubectl logs <nginx-pod-name> -n php-iibs
```

### Problème : PHP ne peut pas se connecter à MySQL

**Symptôme** :
```
Error: SQLSTATE[HY000] [2002] Connection refused
```

**Solutions** :

1. **Vérifier que MySQL tourne** :
```bash
kubectl get pods -n php-iibs | grep mysql
```

2. **Tester la connectivité réseau** :
```bash
# Entrer dans un Pod PHP
kubectl exec -it <php-pod-name> -n php-iibs -- /bin/bash

# Tester la connexion à MySQL
apt-get update && apt-get install -y telnet
telnet mysql-service 3306

# Ou avec ping
apt-get install -y iputils-ping
ping mysql-service
```

3. **Vérifier les variables d'environnement** :
```bash
kubectl exec <php-pod-name> -n php-iibs -- env | grep MYSQL
```

4. **Vérifier le Service MySQL** :
```bash
kubectl describe service mysql-service -n php-iibs
# Vérifier que le selector correspond aux labels du Pod MySQL
```

### Problème : Le PVC reste en "Pending"

**Symptôme** :
```bash
kubectl get pvc -n php-iibs
NAME        STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mysql-pvc   Pending                                                    5m
```

**Solutions** :

1. **Vérifier les événements** :
```bash
kubectl describe pvc mysql-pvc -n php-iibs
```

2. **Vérifier les StorageClasses disponibles** :
```bash
kubectl get storageclass
```

3. **Créer une StorageClass par défaut (Minikube)** :
```bash
kubectl get storageclass
# Si "standard" existe :
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

4. **Créer un PV manuellement (pour tests locaux)** :
```yaml
# pv-manual.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mysql-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /data/mysql
```

```bash
kubectl apply -f pv-manual.yaml
```

---

## Aller plus loin

### 1. Créer vos propres images Docker

Pour une vraie production, vous devez créer et pusher vos images personnalisées.

#### Étape 1 : Builder les images

```bash
# Image PHP
cd php/
docker build -t votre-username/php-iibs:v1 .

# Image Nginx
cd ../nginx/
docker build -t votre-username/nginx-iibs:v1 .
```

#### Étape 2 : Pusher vers un registry

```bash
# Docker Hub
docker login
docker push votre-username/php-iibs:v1
docker push votre-username/nginx-iibs:v1

# Ou GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
docker tag votre-username/php-iibs:v1 ghcr.io/username/php-iibs:v1
docker push ghcr.io/username/php-iibs:v1
```

#### Étape 3 : Mettre à jour les Deployments

Dans `05-php-deployment.yaml` :
```yaml
containers:
- name: php-fpm
  image: votre-username/php-iibs:v1  # Votre image personnalisée
```

Dans `06-nginx-deployment.yaml` :
```yaml
containers:
- name: nginx
  image: votre-username/nginx-iibs:v1  # Votre image personnalisée
```

### 2. Utiliser un Ingress (pour production)

Un Ingress permet d'exposer plusieurs services avec des noms de domaine et SSL/TLS.

#### Installation d'un Ingress Controller (Minikube)

```bash
minikube addons enable ingress
```

#### Création d'un Ingress

```yaml
# k8s/07-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: php-iibs-ingress
  namespace: php-iibs
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: php-iibs.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
```

```bash
# Déployer
kubectl apply -f k8s/07-ingress.yaml

# Ajouter dans /etc/hosts (Linux/Mac) ou C:\Windows\System32\drivers\etc\hosts (Windows)
<minikube-ip> php-iibs.local

# Accéder via : http://php-iibs.local
```

### 3. Autoscaling (Horizontal Pod Autoscaler)

Scaler automatiquement en fonction de la charge CPU/RAM.

```yaml
# k8s/08-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
  namespace: php-iibs
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70  # Scaler si CPU > 70%
```

```bash
kubectl apply -f k8s/08-hpa.yaml
kubectl get hpa -n php-iibs
```

### 4. Monitoring avec Prometheus et Grafana

```bash
# Installer Prometheus Operator
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring

# Accéder à Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Username: admin, Password: prom-operator
```

### 5. CI/CD avec GitHub Actions

Exemple de workflow pour déployer automatiquement :

```yaml
# .github/workflows/deploy-k8s.yml
name: Deploy to Kubernetes

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2

    - name: Build Docker images
      run: |
        docker build -t ${{ secrets.DOCKER_USERNAME }}/php-iibs:${{ github.sha }} ./php
        docker build -t ${{ secrets.DOCKER_USERNAME }}/nginx-iibs:${{ github.sha }} ./nginx

    - name: Push to Docker Hub
      run: |
        echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
        docker push ${{ secrets.DOCKER_USERNAME }}/php-iibs:${{ github.sha }}
        docker push ${{ secrets.DOCKER_USERNAME }}/nginx-iibs:${{ github.sha }}

    - name: Deploy to Kubernetes
      run: |
        kubectl apply -k k8s/
        kubectl set image deployment/php-deployment php-fpm=${{ secrets.DOCKER_USERNAME }}/php-iibs:${{ github.sha }} -n php-iibs
        kubectl set image deployment/nginx-deployment nginx=${{ secrets.DOCKER_USERNAME }}/nginx-iibs:${{ github.sha }} -n php-iibs
```

### 6. Helm Charts (gestionnaire de packages Kubernetes)

Helm est comme "apt" ou "npm" pour Kubernetes.

```bash
# Installer Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Créer un Helm Chart
helm create php-iibs-chart

# Structure :
# php-iibs-chart/
# ├── Chart.yaml
# ├── values.yaml
# ├── templates/
# │   ├── deployment.yaml
# │   ├── service.yaml
# │   └── ...

# Installer le Chart
helm install php-iibs ./php-iibs-chart -n php-iibs

# Mettre à jour
helm upgrade php-iibs ./php-iibs-chart -n php-iibs

# Supprimer
helm uninstall php-iibs -n php-iibs
```

---

## Ressources pour apprendre

### Documentation officielle
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### Tutoriels interactifs
- [Katacoda Kubernetes](https://www.katacoda.com/courses/kubernetes)
- [Play with Kubernetes](https://labs.play-with-k8s.com/)

### Livres recommandés
- "Kubernetes Up & Running" par Kelsey Hightower
- "The Kubernetes Book" par Nigel Poulton

### Certifications
- **CKA** : Certified Kubernetes Administrator
- **CKAD** : Certified Kubernetes Application Developer
- **CKS** : Certified Kubernetes Security Specialist

---

## Conclusion

Félicitations ! Vous avez transformé votre application Docker Compose en une application Kubernetes complète.

**Ce que vous avez appris** :
- Les différences entre Docker et Kubernetes
- Les concepts de base : Pods, Deployments, Services, ConfigMaps, Secrets, PVC
- Comment déployer une application multi-tiers sur Kubernetes
- Les commandes kubectl essentielles
- Les stratégies de dépannage

**Prochaines étapes** :
1. Créer vos propres images Docker personnalisées
2. Mettre en place un Ingress pour l'exposition HTTP/HTTPS
3. Implémenter le monitoring avec Prometheus
4. Configurer le CI/CD automatique
5. Explorer les patterns avancés (StatefulSets, DaemonSets, Jobs, CronJobs)

**Besoin d'aide ?**
- [Kubernetes Slack](https://slack.k8s.io/)
- [Stack Overflow - Kubernetes](https://stackoverflow.com/questions/tagged/kubernetes)
- [Reddit r/kubernetes](https://www.reddit.com/r/kubernetes/)

Bonne chance dans votre apprentissage de Kubernetes ! 🚀
