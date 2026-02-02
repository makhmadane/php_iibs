# Guide de Démarrage Rapide - 5 minutes pour déployer !

Ce guide vous permet de déployer votre application sur Kubernetes en moins de 5 minutes.

## Prérequis (Installation rapide)

### 1. Installer kubectl

**Windows (PowerShell en admin)** :
```powershell
choco install kubernetes-cli
# Ou télécharger : https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
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

### 2. Installer Minikube (cluster local)

**Windows (PowerShell en admin)** :
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

### 3. Démarrer Minikube

```bash
minikube start
```

Vérifier :
```bash
kubectl cluster-info
kubectl get nodes
```

## Déploiement en 3 commandes

### Méthode 1 : Avec le script (Recommandé)

**Linux/macOS** :
```bash
cd k8s/
./deploy.sh deploy
```

**Windows PowerShell** :
```powershell
cd k8s
.\deploy.ps1 deploy
```

### Méthode 2 : Avec kubectl

```bash
cd k8s/
kubectl apply -k .
```

## Vérifier le déploiement

```bash
# Voir tous les pods
kubectl get pods -n php-iibs

# Attendre que tous soient "Running" (1-2 minutes)
kubectl wait --for=condition=ready pod --all -n php-iibs --timeout=120s

# Voir les services
kubectl get services -n php-iibs
```

## Accéder à l'application

### Avec Minikube

```bash
# Option 1 : Ouvrir automatiquement dans le navigateur
minikube service nginx-service -n php-iibs

# Option 2 : Obtenir l'URL
minikube service nginx-service -n php-iibs --url
# Puis ouvrir : http://<minikube-ip>:30080
```

### Avec Docker Desktop ou autre cluster

Ouvrir dans votre navigateur :
```
http://localhost:30080
```

## Commandes utiles

### Voir l'état

```bash
# Statut complet
kubectl get all -n php-iibs

# Logs Nginx
kubectl logs -l app=nginx -n php-iibs --tail=50

# Logs PHP
kubectl logs -l app=php -n php-iibs --tail=50

# Logs MySQL
kubectl logs -l app=mysql -n php-iibs --tail=50
```

### Scaler l'application

```bash
# Augmenter les réplicas Nginx à 3
kubectl scale deployment nginx-deployment --replicas=3 -n php-iibs

# Augmenter les réplicas PHP à 5
kubectl scale deployment php-deployment --replicas=5 -n php-iibs

# Vérifier
kubectl get pods -n php-iibs
```

### Entrer dans un pod (debugging)

```bash
# Lister les pods
kubectl get pods -n php-iibs

# Entrer dans un pod Nginx
kubectl exec -it <nginx-pod-name> -n php-iibs -- /bin/sh

# Entrer dans un pod PHP
kubectl exec -it <php-pod-name> -n php-iibs -- /bin/bash

# Entrer dans le pod MySQL
kubectl exec -it <mysql-pod-name> -n php-iibs -- mysql -uroot -proot
```

## Nettoyer / Supprimer

### Avec le script

**Linux/macOS** :
```bash
./deploy.sh delete
```

**Windows** :
```powershell
.\deploy.ps1 delete
```

### Avec kubectl

```bash
# Supprimer toute l'application
kubectl delete -k .

# Ou supprimer le namespace (supprime tout)
kubectl delete namespace php-iibs
```

## Problèmes courants

### Les pods ne démarrent pas

```bash
# Voir les événements
kubectl get events -n php-iibs --sort-by='.lastTimestamp'

# Voir les détails d'un pod
kubectl describe pod <pod-name> -n php-iibs
```

### L'application n'est pas accessible

```bash
# Vérifier que les pods sont "Running"
kubectl get pods -n php-iibs

# Vérifier le service
kubectl get service nginx-service -n php-iibs

# Tester avec port-forward
kubectl port-forward service/nginx-service 8080:80 -n php-iibs
# Puis ouvrir : http://localhost:8080
```

### Le PVC reste en "Pending"

```bash
# Vérifier les StorageClasses
kubectl get storageclass

# Si aucune n'est "default", marquer une comme défaut
kubectl patch storageclass standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## Prochaines étapes

Une fois que l'application fonctionne :

1. **Lire le README.md complet** pour comprendre tous les concepts
2. **Explorer ARCHITECTURE.md** pour visualiser l'architecture
3. **Modifier les fichiers YAML** et redéployer pour voir les changements
4. **Tester le scaling** : augmenter/diminuer les réplicas
5. **Voir les logs en temps réel** : `kubectl logs -f <pod-name> -n php-iibs`
6. **Expérimenter les mises à jour** : changer l'image d'un Deployment

## Commandes de diagnostic

```bash
# Voir les ressources consommées
kubectl top nodes
kubectl top pods -n php-iibs

# Voir la configuration d'un pod en YAML
kubectl get pod <pod-name> -n php-iibs -o yaml

# Tester la connectivité réseau
kubectl run -it --rm debug --image=busybox --restart=Never -n php-iibs -- sh
# Dans le shell : nslookup mysql-service

# Voir l'historique des rollouts
kubectl rollout history deployment/nginx-deployment -n php-iibs
```

## Aide

Pour plus d'informations :
- `./deploy.sh help` (Linux/macOS)
- `.\deploy.ps1 help` (Windows)
- Lire README.md pour un guide complet
- Lire ARCHITECTURE.md pour comprendre l'architecture

Bon déploiement ! 🚀
