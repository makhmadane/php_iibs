# Cours Complet Kubernetes (K8s)

## Table des matières
1. [Introduction](#introduction)
2. [Architecture Globale](#architecture-globale)
3. [Control Plane (Le Cerveau)](#control-plane-le-cerveau)
4. [Worker Nodes (Les Ouvriers)](#worker-nodes-les-ouvriers)
5. [Les Objets Kubernetes](#les-objets-kubernetes)
6. [Namespaces](#namespaces---lisolation-logique)
7. [ConfigMaps](#configmaps---configuration-externe)
8. [Secrets](#secrets---données-sensibles)
9. [Volumes](#volumes---stockage-persistant)
10. [Ingress](#ingress---routage-http-intelligent)
11. [Labels & Selectors](#labels--selectors---lorganisation)
12. [Probes (Health Checks)](#probes---health-checks)
13. [Horizontal Pod Autoscaler](#horizontal-pod-autoscaler-hpa)
14. [Commandes Essentielles](#commandes-essentielles)

---

## Introduction

### C'est quoi Kubernetes (K8s) ?

**Kubernetes** = un **orchestrateur de conteneurs**.

Imagine : tu as 100 conteneurs Docker à gérer. Manuellement c'est impossible. K8s automatise tout :
- Déploiement
- Mise à l'échelle (scaling)
- Réparation automatique (self-healing)
- Load balancing

---

## Architecture Globale

```
┌────────────────────────────────────────────────────────────────────┐
│                            CLUSTER K8s                             │
│                                                                    │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                     CONTROL PLANE (Master)                   │  │
│  │                                                              │  │
│  │   ┌─────────────┐  ┌───────────┐  ┌──────────────────────┐   │  │
│  │   │ API Server  │  │   etcd    │  │  Controller Manager  │   │  │
│  │   │             │  │           │  │                      │   │  │
│  │   │ Point       │  │ Base de   │  │ - Node Controller    │   │  │
│  │   │ d'entrée    │  │ données   │  │ - Replication Ctrl   │   │  │
│  │   │ kubectl     │  │ clé-valeur│  │ - Endpoint Ctrl      │   │  │
│  │   └─────────────┘  └───────────┘  └──────────────────────┘   │  │
│  │                                                              │  │
│  │   ┌─────────────────────────────────────────────────────┐    │  │
│  │   │                    SCHEDULER                        │    │  │
│  │   │  Décide où placer les Pods (quel Worker Node)       │    │  │
│  │   └─────────────────────────────────────────────────────┘    │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                               │                                    │
│                               │ Communication                      │
│                               ▼                                    │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                       WORKER NODES                           │  │
│  │                                                              │  │
│  │  ┌─────────────────────┐      ┌─────────────────────┐        │  │
│  │  │     WORKER 1        │      │     WORKER 2        │        │  │
│  │  │                     │      │                     │        │  │
│  │  │  ┌───────────────┐  │      │  ┌───────────────┐  │        │  │
│  │  │  │    kubelet    │  │      │  │    kubelet    │  │        │  │
│  │  │  └───────────────┘  │      │  └───────────────┘  │        │  │
│  │  │  ┌───────────────┐  │      │  ┌───────────────┐  │        │  │
│  │  │  │  kube-proxy   │  │      │  │  kube-proxy   │  │        │  │
│  │  │  └───────────────┘  │      │  └───────────────┘  │        │  │
│  │  │  ┌───────────────┐  │      │  ┌───────────────┐  │        │  │
│  │  │  │Container      │  │      │  │Container      │  │        │  │
│  │  │  │Runtime(Docker)│  │      │  │Runtime(Docker)│  │        │  │
│  │  │  └───────────────┘  │      │  └───────────────┘  │        │  │
│  │  │                     │      │                     │        │  │
│  │  │  ┌─────┐ ┌─────┐   │      │  ┌─────┐ ┌─────┐   │        │  │
│  │  │  │ Pod │ │ Pod │   │      │  │ Pod │ │ Pod │   │        │  │
│  │  │  └─────┘ └─────┘   │      │  └─────┘ └─────┘   │        │  │
│  │  └─────────────────────┘      └─────────────────────┘        │  │
│  └──────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────────┘
```

### Composants principaux

| Composant | Rôle | Analogie |
|-----------|------|----------|
| **Cluster** | Infrastructure complète | L'usine entière |
| **Control Plane** | Gestion/décision | La direction |
| **API Server** | Point d'entrée | L'accueil |
| **etcd** | Stockage état | Les archives |
| **Scheduler** | Placement pods | Le planificateur RH |
| **Controller Manager** | Maintien état désiré | Le contrôle qualité |
| **Worker Node** | Exécution | Les ouvriers |
| **kubelet** | Agent local | Le chef d'équipe |
| **kube-proxy** | Réseau | Le standard téléphonique |

---

## Control Plane (Le Cerveau)

### 1. API Server - Le Réceptionniste

```
Toi (kubectl) ──► API Server ──► Cluster
```

- **Seul point d'entrée** pour communiquer avec le cluster
- Reçoit toutes les commandes : `kubectl get pods`, `kubectl apply`, etc.
- Valide les requêtes et les transmet aux bons composants

**Exemple concret :**
```bash
kubectl create deployment nginx --image=nginx
# Cette commande → API Server → Scheduler → Worker Node
```

### 2. etcd - La Mémoire

```
┌─────────────────────────────────┐
│             etcd                │
│                                 │
│  "pod-1": "running on node-2"   │
│  "service-web": "10.0.0.5"      │
│  "replicas": 3                  │
│  "config": {...}                │
└─────────────────────────────────┘
```

- Base de données **clé-valeur** distribuée
- Stocke **TOUT l'état** du cluster
- Si etcd est perdu = cluster perdu
- C'est pour ça qu'on fait des backups de etcd

### 3. Scheduler - Le Planificateur

```
Nouveau Pod créé
       │
       ▼
┌─────────────────────────────────────────────┐
│              SCHEDULER                      │
│                                             │
│  Analyse :                                  │
│  - CPU/RAM disponibles sur chaque node     │
│  - Affinités/Anti-affinités                │
│  - Taints et Tolerations                   │
│                                             │
│  Décision : "Ce Pod ira sur Worker-2"      │
└─────────────────────────────────────────────┘
```

**Critères de décision :**
- Ressources disponibles (CPU, RAM)
- Contraintes définies (nodeSelector, affinity)
- Équilibrage de charge entre nodes

### 4. Controller Manager - Le Surveillant

```
┌─────────────────────────────────────────────────────┐
│              CONTROLLER MANAGER                     │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │ Replication Controller                      │    │
│  │ "Tu veux 3 replicas ? J'en vois 2..."      │    │
│  │ "Je crée le 3ème !"                        │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │ Node Controller                             │    │
│  │ "Worker-3 ne répond plus depuis 5min..."   │    │
│  │ "Je le marque comme NotReady"              │    │
│  └─────────────────────────────────────────────┘    │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │ Endpoint Controller                         │    │
│  │ "Ce Service doit pointer vers ces Pods"    │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

**Principe : Boucle de réconciliation**
```
État Désiré (YAML) ──► Comparer ──► État Actuel
                          │
                          ▼
                   Différence ?
                      │    │
                     OUI  NON
                      │    │
                      ▼    ▼
                   Corriger  OK
```

---

## Worker Nodes (Les Ouvriers)

### 1. kubelet - L'Agent Local

```
┌─────────────────────────────────────────┐
│              WORKER NODE                │
│                                         │
│   ┌─────────────────────────────────┐   │
│   │           kubelet               │   │
│   │                                 │   │
│   │  • Reçoit les ordres du Master  │   │
│   │  • Démarre/arrête les Pods      │   │
│   │  • Surveille la santé des Pods  │   │
│   │  • Rapporte l'état au Master    │   │
│   └─────────────────────────────────┘   │
│                  │                      │
│                  ▼                      │
│   ┌─────────────────────────────────┐   │
│   │      Container Runtime          │   │
│   │      (Docker/containerd)        │   │
│   └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### 2. kube-proxy - Le Réseau

```
┌──────────────────────────────────────────────────────┐
│                    kube-proxy                        │
│                                                      │
│   Requête vers Service "web" (10.96.0.10:80)        │
│                      │                               │
│                      ▼                               │
│   ┌──────────────────────────────────────────────┐   │
│   │           RÈGLES IPTABLES / IPVS             │   │
│   │                                              │   │
│   │  10.96.0.10:80 ──► Pod-1 (10.244.1.5:80)    │   │
│   │                ──► Pod-2 (10.244.2.8:80)    │   │
│   │                ──► Pod-3 (10.244.1.12:80)   │   │
│   └──────────────────────────────────────────────┘   │
│                                                      │
│   Load Balancing entre les Pods                      │
└──────────────────────────────────────────────────────┘
```

---

## Les Objets Kubernetes

### POD - L'unité de base

```
┌─────────────────────────────────────────┐
│                  POD                    │
│           (plus petite unité)           │
│                                         │
│   ┌─────────────┐  ┌─────────────┐      │
│   │ Container 1 │  │ Container 2 │      │
│   │   (nginx)   │  │  (sidecar)  │      │
│   └─────────────┘  └─────────────┘      │
│                                         │
│   Partagent :                           │
│   • Même adresse IP                     │
│   • Même namespace réseau               │
│   • Mêmes volumes                       │
└─────────────────────────────────────────┘
```

**YAML exemple :**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mon-pod
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

### REPLICASET - La Garantie de Disponibilité

```
┌──────────────────────────────────────────────────────────┐
│                      REPLICASET                          │
│                   replicas: 3                            │
│                                                          │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐              │
│   │  Pod 1  │    │  Pod 2  │    │  Pod 3  │              │
│   │  nginx  │    │  nginx  │    │  nginx  │              │
│   └─────────┘    └─────────┘    └─────────┘              │
│       ✓              ✓              ✓                    │
│                                                          │
│   Si Pod 2 meurt :                                       │
│                                                          │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐              │
│   │  Pod 1  │    │   ☠️    │    │  Pod 3  │              │
│   │  nginx  │    │  DEAD   │    │  nginx  │              │
│   └─────────┘    └─────────┘    └─────────┘              │
│       ✓              ✗              ✓                    │
│                                                          │
│   ReplicaSet détecte : "J'ai 2/3 pods"                  │
│   Action : Créer un nouveau Pod                          │
│                                                          │
│   ┌─────────┐    ┌─────────┐    ┌─────────┐              │
│   │  Pod 1  │    │  Pod 4  │    │  Pod 3  │              │
│   │  nginx  │    │  nginx  │    │  nginx  │              │
│   └─────────┘    └─────────┘    └─────────┘              │
│       ✓              ✓              ✓                    │
└──────────────────────────────────────────────────────────┘
```

### DEPLOYMENT - Le Gestionnaire Intelligent

```
┌───────────────────────────────────────────────────────────────┐
│                        DEPLOYMENT                             │
│                                                               │
│   Gère :                                                      │
│   • ReplicaSets                                               │
│   • Rolling Updates (mise à jour progressive)                 │
│   • Rollbacks (retour arrière)                                │
│                                                               │
│   ┌─────────────────────────────────────────────────────┐     │
│   │                  ROLLING UPDATE                     │     │
│   │                                                     │     │
│   │   v1    v1    v1         v1    v1    v2            │     │
│   │   [█]   [█]   [█]   ──►  [█]   [█]   [█]           │     │
│   │                                                     │     │
│   │   v1    v2    v2         v2    v2    v2            │     │
│   │   [█]   [█]   [█]   ──►  [█]   [█]   [█]           │     │
│   │                                                     │     │
│   │   Zero downtime !                                   │     │
│   └─────────────────────────────────────────────────────┘     │
└───────────────────────────────────────────────────────────────┘
```

**YAML exemple :**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        ports:
        - containerPort: 80
```

### SERVICE - L'Exposition Réseau

```
┌──────────────────────────────────────────────────────────────────┐
│                         SERVICES                                 │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ ClusterIP (défaut)                                         │  │
│  │                                                            │  │
│  │   Accessible uniquement DANS le cluster                    │  │
│  │   IP interne : 10.96.0.10                                  │  │
│  │                                                            │  │
│  │   [Pod A] ──► Service ──► [Pod 1, Pod 2, Pod 3]           │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ NodePort                                                   │  │
│  │                                                            │  │
│  │   Expose sur un port de chaque Node (30000-32767)         │  │
│  │                                                            │  │
│  │   Internet ──► Node:30080 ──► Service ──► Pods            │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ LoadBalancer                                               │  │
│  │                                                            │  │
│  │   Crée un Load Balancer externe (cloud)                   │  │
│  │                                                            │  │
│  │   Internet ──► LB (IP publique) ──► Service ──► Pods      │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

**YAML exemple :**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: mon-service
spec:
  type: ClusterIP  # ou NodePort, LoadBalancer
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
```

---

## Namespaces - L'Isolation Logique

```
┌─────────────────────────────────────────────────────────────────┐
│                         CLUSTER K8s                             │
│                                                                 │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │   namespace:    │  │   namespace:    │  │   namespace:    │  │
│  │     default     │  │   production    │  │   development   │  │
│  │                 │  │                 │  │                 │  │
│  │  [Pod A]        │  │  [Pod A]        │  │  [Pod A]        │  │
│  │  [Pod B]        │  │  [Pod B]        │  │  [Pod B]        │  │
│  │  [Service X]    │  │  [Service X]    │  │  [Service X]    │  │
│  │                 │  │                 │  │                 │  │
│  │  Même nom OK !  │  │  Même nom OK !  │  │  Même nom OK !  │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘  │
│                                                                 │
│  Isolation : quotas, permissions, ressources par namespace      │
└─────────────────────────────────────────────────────────────────┘
```

**Namespaces par défaut :**
```bash
kubectl get namespaces

NAME              STATUS   AGE
default           Active   1d    # Tes apps par défaut
kube-system       Active   1d    # Composants K8s (coredns, etc.)
kube-public       Active   1d    # Ressources publiques
kube-node-lease   Active   1d    # Heartbeat des nodes
```

**Utilisation :**
```bash
# Créer un namespace
kubectl create namespace dev

# Déployer dans un namespace
kubectl apply -f app.yaml -n dev

# Lister les pods d'un namespace
kubectl get pods -n dev
```

---

## ConfigMaps - Configuration Externe

```
┌──────────────────────────────────────────────────────────────┐
│                       CONFIGMAP                              │
│                                                              │
│   Stocke la configuration NON SENSIBLE                       │
│                                                              │
│   ┌────────────────────────────────────────────────────┐     │
│   │  app-config:                                       │     │
│   │    DATABASE_HOST: "mysql-service"                  │     │
│   │    DATABASE_PORT: "3306"                           │     │
│   │    LOG_LEVEL: "info"                               │     │
│   │    MAX_CONNECTIONS: "100"                          │     │
│   └────────────────────────────────────────────────────┘     │
│                          │                                   │
│                          ▼                                   │
│   ┌────────────────────────────────────────────────────┐     │
│   │                      POD                           │     │
│   │                                                    │     │
│   │   Variables d'environnement :                      │     │
│   │   DATABASE_HOST=mysql-service                      │     │
│   │   LOG_LEVEL=info                                   │     │
│   │                                                    │     │
│   │   OU monté comme fichier :                         │     │
│   │   /etc/config/app.properties                       │     │
│   └────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────┘
```

**YAML exemple :**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_HOST: "mysql-service"
  DATABASE_PORT: "3306"
  LOG_LEVEL: "info"
---
# Utilisation dans un Pod
apiVersion: v1
kind: Pod
metadata:
  name: mon-app
spec:
  containers:
  - name: app
    image: mon-app:latest
    envFrom:
    - configMapRef:
        name: app-config   # Injecte toutes les clés
```

---

## Secrets - Données Sensibles

```
┌──────────────────────────────────────────────────────────────┐
│                        SECRETS                               │
│                                                              │
│   Comme ConfigMap mais pour données SENSIBLES                │
│   Stocké encodé en Base64 (pas chiffré par défaut !)        │
│                                                              │
│   ┌────────────────────────────────────────────────────┐     │
│   │  db-credentials:                                   │     │
│   │    username: YWRtaW4=        (admin)              │     │
│   │    password: cGFzc3dvcmQxMjM= (password123)       │     │
│   └────────────────────────────────────────────────────┘     │
│                          │                                   │
│                          ▼                                   │
│   ┌────────────────────────────────────────────────────┐     │
│   │                      POD                           │     │
│   │                                                    │     │
│   │   Variables (décodées automatiquement) :           │     │
│   │   DB_USERNAME=admin                                │     │
│   │   DB_PASSWORD=password123                          │     │
│   └────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────┘
```

**Types de Secrets :**

| Type | Usage |
|------|-------|
| Opaque | Données arbitraires (défaut) |
| docker-registry | Credentials Docker Hub |
| tls | Certificats TLS |
| basic-auth | Authentification basique |

**Création :**
```bash
# Depuis la ligne de commande
kubectl create secret generic db-creds \
  --from-literal=username=admin \
  --from-literal=password=motdepasse123

# Pour Docker Hub
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=ton-user \
  --docker-password=ton-password
```

**YAML exemple :**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
data:
  username: YWRtaW4=          # echo -n 'admin' | base64
  password: cGFzc3dvcmQxMjM=  # echo -n 'password123' | base64
---
# Utilisation dans un Pod
apiVersion: v1
kind: Pod
metadata:
  name: mon-app
spec:
  containers:
  - name: app
    image: mon-app:latest
    env:
    - name: DB_USERNAME
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: username
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: password
```

---

## Volumes - Stockage Persistant

### Le Problème

```
Pod démarre ──► Écrit des données ──► Pod meurt ──► DONNÉES PERDUES
```

### La Solution

```
┌──────────────────────────────────────────────────────────────────┐
│                    SOLUTION AVEC VOLUME                          │
│                                                                  │
│   ┌─────────────────────────────────────────────────────────┐    │
│   │              PersistentVolume (PV)                      │    │
│   │                                                         │    │
│   │   Stockage physique (disque, NFS, cloud storage)        │    │
│   │   Existe indépendamment des Pods                        │    │
│   │   Capacité : 10Gi                                       │    │
│   └─────────────────────────────────────────────────────────┘    │
│                            ▲                                     │
│                            │ Lié                                 │
│                            ▼                                     │
│   ┌─────────────────────────────────────────────────────────┐    │
│   │           PersistentVolumeClaim (PVC)                   │    │
│   │                                                         │    │
│   │   "Je demande 5Gi de stockage"                          │    │
│   │   Le Pod utilise ce PVC                                 │    │
│   └─────────────────────────────────────────────────────────┘    │
│                            ▲                                     │
│                            │ Monte                               │
│                            ▼                                     │
│   ┌─────────────────────────────────────────────────────────┐    │
│   │                        POD                              │    │
│   │                                                         │    │
│   │   Volume monté sur /data                                │    │
│   │   Données persistantes même si Pod restart              │    │
│   └─────────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────────┘
```

**YAML exemple :**
```yaml
# PersistentVolumeClaim
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
---
# Pod utilisant le PVC
apiVersion: v1
kind: Pod
metadata:
  name: mysql
spec:
  containers:
  - name: mysql
    image: mysql:8.0
    volumeMounts:
    - name: mysql-storage
      mountPath: /var/lib/mysql
  volumes:
  - name: mysql-storage
    persistentVolumeClaim:
      claimName: mysql-pvc
```

### Access Modes

| Mode | Description |
|------|-------------|
| ReadWriteOnce (RWO) | Lecture/écriture par un seul node |
| ReadOnlyMany (ROX) | Lecture seule par plusieurs nodes |
| ReadWriteMany (RWX) | Lecture/écriture par plusieurs nodes |

---

## Ingress - Routage HTTP Intelligent

### Sans Ingress (Coûteux)

```
Internet ──► LoadBalancer 1 ($$$) ──► Service A
         ──► LoadBalancer 2 ($$$) ──► Service B
         ──► LoadBalancer 3 ($$$) ──► Service C
```

### Avec Ingress (Économique)

```
┌──────────────────────────────────────────────────────────────────────┐
│                           AVEC INGRESS                               │
│                                                                      │
│                        ┌─────────────────┐                           │
│   Internet ──────────► │    INGRESS      │                           │
│                        │   CONTROLLER    │                           │
│                        │  (nginx/traefik)│                           │
│                        └────────┬────────┘                           │
│                                 │                                    │
│              ┌──────────────────┼──────────────────┐                 │
│              │                  │                  │                 │
│              ▼                  ▼                  ▼                 │
│   ┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐        │
│   │ api.monsite.com  │ │ monsite.com  │ │ admin.monsite.com│        │
│   │        │         │ │      │       │ │        │         │        │
│   │        ▼         │ │      ▼       │ │        ▼         │        │
│   │   Service API    │ │ Service Web  │ │  Service Admin   │        │
│   └──────────────────┘ └──────────────┘ └──────────────────┘        │
│                                                                      │
│   1 seul point d'entrée = Économique + Flexible                     │
└──────────────────────────────────────────────────────────────────────┘
```

**Règles de routage :**

| Type | Exemple | Destination |
|------|---------|-------------|
| Par HOST | api.example.com | service-api:80 |
| Par HOST | www.example.com | service-web:80 |
| Par PATH | example.com/api | service-api:80 |
| Par PATH | example.com/ | service-web:80 |

**YAML exemple :**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mon-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: api.monsite.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
  - host: www.monsite.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service
            port:
              number: 80
```

---

## Labels & Selectors - L'Organisation

```
┌──────────────────────────────────────────────────────────────────┐
│                      LABELS (Étiquettes)                         │
│                                                                  │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│   │    Pod 1    │  │    Pod 2    │  │    Pod 3    │              │
│   │             │  │             │  │             │              │
│   │ app: web    │  │ app: web    │  │ app: api    │              │
│   │ env: prod   │  │ env: dev    │  │ env: prod   │              │
│   │ tier: front │  │ tier: front │  │ tier: back  │              │
│   └─────────────┘  └─────────────┘  └─────────────┘              │
│                                                                  │
│   SELECTOR : "app=web"          → Résultat : Pod 1, Pod 2       │
│   SELECTOR : "app=web,env=prod" → Résultat : Pod 1              │
└──────────────────────────────────────────────────────────────────┘
```

**Commandes utiles :**
```bash
# Filtrer par label
kubectl get pods -l app=web
kubectl get pods -l app=web,env=prod

# Ajouter un label
kubectl label pod mon-pod version=v2

# Supprimer un label
kubectl label pod mon-pod version-
```

---

## Probes - Health Checks

### Types de Probes

```
┌──────────────────────────────────────────────────────────────────┐
│                         PROBES                                   │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ LIVENESS PROBE                                             │  │
│  │                                                            │  │
│  │ "Est-ce que le conteneur est VIVANT ?"                    │  │
│  │ Si échec → K8s RESTART le conteneur                       │  │
│  │ Exemple : L'app est bloquée (deadlock)                    │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ READINESS PROBE                                            │  │
│  │                                                            │  │
│  │ "Est-ce que le conteneur est PRÊT à recevoir du trafic ?" │  │
│  │ Si échec → K8s RETIRE le Pod du Service                   │  │
│  │ Exemple : L'app démarre mais charge encore ses caches     │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ STARTUP PROBE                                              │  │
│  │                                                            │  │
│  │ "Est-ce que le conteneur a fini de DÉMARRER ?"            │  │
│  │ Désactive liveness/readiness pendant le démarrage         │  │
│  │ Exemple : App legacy avec démarrage lent                  │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

### Types de vérification

```yaml
# HTTP GET
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5

# TCP Socket
livenessProbe:
  tcpSocket:
    port: 3306
  initialDelaySeconds: 15

# Exec Command
livenessProbe:
  exec:
    command:
    - cat
    - /tmp/healthy
```

---

## Horizontal Pod Autoscaler (HPA)

```
┌──────────────────────────────────────────────────────────────────┐
│                            HPA                                   │
│                                                                  │
│   "Scale automatiquement selon la charge"                        │
│                                                                  │
│   Configuration :                                                │
│   - Min replicas : 2                                             │
│   - Max replicas : 10                                            │
│   - Target CPU : 50%                                             │
│                                                                  │
│   CPU 30% : [Pod] [Pod]                    (2 replicas)         │
│                    │                                             │
│                    ▼                                             │
│   CPU 80% : [Pod] [Pod] [Pod] [Pod]        (scale up → 4)       │
│                    │                                             │
│                    ▼                                             │
│   CPU 20% : [Pod] [Pod]                    (scale down → 2)     │
└──────────────────────────────────────────────────────────────────┘
```

**Commande :**
```bash
kubectl autoscale deployment nginx --cpu-percent=50 --min=2 --max=10
```

**YAML exemple :**
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nginx-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nginx
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

---

## Flux Complet : Déploiement d'une App

```
Étape 1: Tu tapes la commande
─────────────────────────────────────────────────
$ kubectl apply -f deployment.yaml
                │
                ▼
Étape 2: API Server reçoit
─────────────────────────────────────────────────
┌─────────────┐
│ API Server  │ → Valide le YAML
└─────────────┘ → Stocke dans etcd
                │
                ▼
Étape 3: Controller Manager détecte
─────────────────────────────────────────────────
┌────────────────────┐
│ Controller Manager │ → "Nouveau Deployment !"
└────────────────────┘ → Crée un ReplicaSet
                       → ReplicaSet veut 3 Pods
                │
                ▼
Étape 4: Scheduler place les Pods
─────────────────────────────────────────────────
┌───────────┐
│ Scheduler │ → Analyse les ressources
└───────────┘ → "Pod 1 → Worker-1"
              → "Pod 2 → Worker-2"
              → "Pod 3 → Worker-1"
                │
                ▼
Étape 5: kubelet exécute
─────────────────────────────────────────────────
┌─────────────────┐    ┌─────────────────┐
│    Worker-1     │    │    Worker-2     │
│                 │    │                 │
│ kubelet reçoit  │    │ kubelet reçoit  │
│ Docker pull     │    │ Docker pull     │
│ Docker run      │    │ Docker run      │
│                 │    │                 │
│ [Pod1] [Pod3]   │    │    [Pod2]       │
└─────────────────┘    └─────────────────┘
```

---

## Hiérarchie des Objets K8s

```
CLUSTER
   │
   ├── Namespace (isolation logique)
   │      │
   │      ├── Deployment (gère le déploiement)
   │      │      │
   │      │      └── ReplicaSet (garantit N replicas)
   │      │             │
   │      │             └── Pod (conteneur(s))
   │      │
   │      ├── Service (expose les pods)
   │      │      ├── ClusterIP
   │      │      ├── NodePort
   │      │      └── LoadBalancer
   │      │
   │      ├── Ingress (routage HTTP)
   │      │
   │      ├── ConfigMap (config non sensible)
   │      │
   │      ├── Secret (config sensible)
   │      │
   │      ├── PVC (demande de stockage)
   │      │
   │      └── HPA (autoscaling)
   │
   └── PersistentVolume (stockage physique)
```

---

## Commandes Essentielles

### Informations cluster
```bash
kubectl cluster-info
kubectl get nodes
kubectl get namespaces
```

### Gestion des ressources
```bash
# Lister
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get all                    # Tout afficher

# Avec namespace
kubectl get pods -n <namespace>
kubectl get pods --all-namespaces

# Détails
kubectl describe pod <nom>
kubectl describe deployment <nom>
```

### Logs et debug
```bash
kubectl logs <pod>                 # Logs du pod
kubectl logs <pod> -f              # Follow logs
kubectl logs <pod> -c <container>  # Container spécifique

kubectl exec -it <pod> -- /bin/bash   # Shell dans le pod
kubectl get events --sort-by='.lastTimestamp'
kubectl top pods                   # CPU/RAM usage
```

### Déploiement
```bash
kubectl apply -f fichier.yaml      # Créer/Mettre à jour
kubectl delete -f fichier.yaml     # Supprimer
kubectl create deployment nginx --image=nginx
```

### Scaling
```bash
kubectl scale deployment <nom> --replicas=5
kubectl autoscale deployment <nom> --cpu-percent=50 --min=2 --max=10
```

### Rollout (mises à jour)
```bash
kubectl rollout status deployment <nom>
kubectl rollout history deployment <nom>
kubectl rollout undo deployment <nom>           # Rollback
kubectl rollout undo deployment <nom> --to-revision=2
```

### Port forwarding
```bash
kubectl port-forward pod/<nom> 8080:80
kubectl port-forward service/<nom> 8080:80
```

---

## Ressources Additionnelles

- [Documentation officielle Kubernetes](https://kubernetes.io/docs/)
- [Kubernetes Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Play with Kubernetes](https://labs.play-with-k8s.com/)
