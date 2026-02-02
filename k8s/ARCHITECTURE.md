# Architecture Kubernetes - php_iibs

Ce document illustre l'architecture complète de l'application transformée de Docker vers Kubernetes.

## Vue d'ensemble

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         CLUSTER KUBERNETES                                │
│                                                                            │
│  ┌────────────────────────────────────────────────────────────────────┐  │
│  │                     NAMESPACE: php-iibs                             │  │
│  │                                                                      │  │
│  │  ┌──────────────────────────────────────────────────────────────┐  │  │
│  │  │                    FRONTEND TIER                              │  │  │
│  │  │                                                                │  │  │
│  │  │  ┌─────────────────────────────────────────────────────┐     │  │  │
│  │  │  │         nginx-service (NodePort 30080)              │     │  │  │
│  │  │  │         Type: NodePort                              │     │  │  │
│  │  │  │         ClusterIP: 10.x.x.x                         │     │  │  │
│  │  │  │         Port: 80 → 30080                            │     │  │  │
│  │  │  └──────────────────┬──────────────────────────────────┘     │  │  │
│  │  │                     │ Load Balancing                         │  │  │
│  │  │         ┌───────────┴────────────┐                           │  │  │
│  │  │         ↓                        ↓                           │  │  │
│  │  │  ┌─────────────┐          ┌─────────────┐                   │  │  │
│  │  │  │ nginx-pod-1 │          │ nginx-pod-2 │                   │  │  │
│  │  │  │             │          │             │                   │  │  │
│  │  │  │ nginx:alpine│          │ nginx:alpine│                   │  │  │
│  │  │  │ Port: 80    │          │ Port: 80    │                   │  │  │
│  │  │  │ CPU: 50-100m│          │ CPU: 50-100m│                   │  │  │
│  │  │  │ RAM: 64-128M│          │ RAM: 64-128M│                   │  │  │
│  │  │  └──────┬──────┘          └──────┬──────┘                   │  │  │
│  │  │         │                        │                           │  │  │
│  │  │         │ Volumes montés:        │                           │  │  │
│  │  │         │ - nginx-config (CM)    │                           │  │  │
│  │  │         │ - php-files (CM)       │                           │  │  │
│  │  │         │                        │                           │  │  │
│  │  └─────────┼────────────────────────┼───────────────────────────┘  │  │
│  │            │                        │                              │  │
│  │            └────────────┬───────────┘                              │  │
│  │                         │ Proxy PHP requests                       │  │
│  │                         ↓                                          │  │
│  │  ┌──────────────────────────────────────────────────────────────┐  │  │
│  │  │                    BACKEND TIER                               │  │  │
│  │  │                                                                │  │  │
│  │  │  ┌─────────────────────────────────────────────────────┐     │  │  │
│  │  │  │         php-service (ClusterIP)                     │     │  │  │
│  │  │  │         Type: ClusterIP                             │     │  │  │
│  │  │  │         ClusterIP: 10.x.x.x                         │     │  │  │
│  │  │  │         Port: 9000                                  │     │  │  │
│  │  │  └──────────────────┬──────────────────────────────────┘     │  │  │
│  │  │                     │ Load Balancing                         │  │  │
│  │  │         ┌───────────┴────────────┐                           │  │  │
│  │  │         ↓                        ↓                           │  │  │
│  │  │  ┌─────────────┐          ┌─────────────┐                   │  │  │
│  │  │  │ php-pod-1   │          │ php-pod-2   │                   │  │  │
│  │  │  │             │          │             │                   │  │  │
│  │  │  │ php:8.2-fpm │          │ php:8.2-fpm │                   │  │  │
│  │  │  │ Port: 9000  │          │ Port: 9000  │                   │  │  │
│  │  │  │ CPU: 100-200│          │ CPU: 100-200│                   │  │  │
│  │  │  │ RAM: 128-256│          │ RAM: 128-256│                   │  │  │
│  │  │  └──────┬──────┘          └──────┬──────┘                   │  │  │
│  │  │         │                        │                           │  │  │
│  │  │         │ Volumes montés:        │                           │  │  │
│  │  │         │ - php-files (CM)       │                           │  │  │
│  │  │         │                        │                           │  │  │
│  │  └─────────┼────────────────────────┼───────────────────────────┘  │  │
│  │            │                        │                              │  │
│  │            └────────────┬───────────┘                              │  │
│  │                         │ MySQL queries                            │  │
│  │                         ↓                                          │  │
│  │  ┌──────────────────────────────────────────────────────────────┐  │  │
│  │  │                    DATABASE TIER                              │  │  │
│  │  │                                                                │  │  │
│  │  │  ┌─────────────────────────────────────────────────────┐     │  │  │
│  │  │  │         mysql-service (ClusterIP)                   │     │  │  │
│  │  │  │         Type: ClusterIP                             │     │  │  │
│  │  │  │         ClusterIP: 10.x.x.x                         │     │  │  │
│  │  │  │         Port: 3306                                  │     │  │  │
│  │  │  └──────────────────┬──────────────────────────────────┘     │  │  │
│  │  │                     │                                         │  │  │
│  │  │                     ↓                                         │  │  │
│  │  │  ┌─────────────────────────────────────────────┐             │  │  │
│  │  │  │         mysql-pod                            │             │  │  │
│  │  │  │                                              │             │  │  │
│  │  │  │  mysql:8                                     │             │  │  │
│  │  │  │  Port: 3306                                  │             │  │  │
│  │  │  │  CPU: 250-500m                               │             │  │  │
│  │  │  │  RAM: 256-512M                               │             │  │  │
│  │  │  │                                              │             │  │  │
│  │  │  │  Volumes montés:                             │             │  │  │
│  │  │  │  - mysql-storage (PVC) → /var/lib/mysql     │             │  │  │
│  │  │  │                                              │             │  │  │
│  │  │  │  Variables d'environnement:                  │             │  │  │
│  │  │  │  - MYSQL_ROOT_PASSWORD (Secret)              │             │  │  │
│  │  │  │  - MYSQL_DATABASE (Secret)                   │             │  │  │
│  │  │  │  - MYSQL_USER (Secret)                       │             │  │  │
│  │  │  │  - MYSQL_PASSWORD (Secret)                   │             │  │  │
│  │  │  └──────────────────┬──────────────────────────┘             │  │  │
│  │  │                     │                                         │  │  │
│  │  │                     ↓                                         │  │  │
│  │  │  ┌─────────────────────────────────────────────┐             │  │  │
│  │  │  │  PersistentVolumeClaim: mysql-pvc            │             │  │  │
│  │  │  │  Size: 1Gi                                   │             │  │  │
│  │  │  │  AccessMode: ReadWriteOnce                   │             │  │  │
│  │  │  │                                              │             │  │  │
│  │  │  │  ↓ Bound to                                  │             │  │  │
│  │  │  │                                              │             │  │  │
│  │  │  │  PersistentVolume (auto-provisioned)         │             │  │  │
│  │  │  │  - Storage on node disk                      │             │  │  │
│  │  │  └─────────────────────────────────────────────┘             │  │  │
│  │  │                                                                │  │  │
│  │  └────────────────────────────────────────────────────────────────┘  │  │
│  │                                                                      │  │
│  │  ┌──────────────────────────────────────────────────────────────┐  │  │
│  │  │                   CONFIGURATION TIER                          │  │  │
│  │  │                                                                │  │  │
│  │  │  ConfigMaps:                                                  │  │  │
│  │  │  ┌─────────────────────────────────────────┐                 │  │  │
│  │  │  │ nginx-config                             │                 │  │  │
│  │  │  │ - default.conf                           │                 │  │  │
│  │  │  └─────────────────────────────────────────┘                 │  │  │
│  │  │                                                                │  │  │
│  │  │  ┌─────────────────────────────────────────┐                 │  │  │
│  │  │  │ php-files                                │                 │  │  │
│  │  │  │ - index.php                              │                 │  │  │
│  │  │  └─────────────────────────────────────────┘                 │  │  │
│  │  │                                                                │  │  │
│  │  │  Secrets:                                                     │  │  │
│  │  │  ┌─────────────────────────────────────────┐                 │  │  │
│  │  │  │ mysql-secret                             │                 │  │  │
│  │  │  │ - MYSQL_ROOT_PASSWORD (base64)           │                 │  │  │
│  │  │  │ - MYSQL_DATABASE (base64)                │                 │  │  │
│  │  │  │ - MYSQL_USER (base64)                    │                 │  │  │
│  │  │  │ - MYSQL_PASSWORD (base64)                │                 │  │  │
│  │  │  └─────────────────────────────────────────┘                 │  │  │
│  │  │                                                                │  │  │
│  │  └────────────────────────────────────────────────────────────────┘  │  │
│  │                                                                      │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                            │
└──────────────────────────────────────────────────────────────────────────┘
```

## Flux de communication

### 1. Requête HTTP entrante

```
Internet
   ↓
http://<node-ip>:30080
   ↓
NodePort Service (nginx-service)
   ↓
Load Balancer (round-robin)
   ↓
nginx-pod-1 ou nginx-pod-2
```

### 2. Traitement PHP

```
nginx-pod
   ↓
fastcgi_pass php-service:9000
   ↓
ClusterIP Service (php-service)
   ↓
Load Balancer (round-robin)
   ↓
php-pod-1 ou php-pod-2
   ↓
Exécute index.php
```

### 3. Requête base de données

```
php-pod
   ↓
mysqli_connect('mysql-service', ...)
   ↓
ClusterIP Service (mysql-service)
   ↓
mysql-pod
   ↓
Lecture/Écriture dans PVC
```

## Comparaison Docker Compose vs Kubernetes

### Docker Compose (avant)

```yaml
services:
  nginx-iibs2:         # → Deployment + Service (NodePort)
    build: ./nginx
    ports:
      - "80:80"        # → Service NodePort 30080
    volumes:
      - ./:/var/www    # → ConfigMap (php-files)
    depends_on:
      - php-iibs2      # → Service discovery automatique

  php-iibs2:           # → Deployment + Service (ClusterIP)
    build: ./php
    volumes:
      - ./:/var/www    # → ConfigMap (php-files)

  mysql-iibs2:         # → Deployment + Service (ClusterIP) + PVC
    image: mysql:8
    environment:       # → Secret (mysql-secret)
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: php_iibs_db
      MYSQL_USER: phpuser
      MYSQL_PASSWORD: secret
    volumes:
      - mysql_data:/var/lib/mysql  # → PersistentVolumeClaim

networks:
  iibs-network:        # → Service networking (automatique dans K8s)

volumes:
  mysql_data:          # → PersistentVolumeClaim + PersistentVolume
```

### Kubernetes (après)

```
00-namespace.yaml          → Namespace: php-iibs
01-mysql-secret.yaml       → Secret pour MySQL
02-nginx-configmap.yaml    → ConfigMap pour nginx config
03-mysql-pvc.yaml          → PVC pour stockage MySQL
04-mysql-deployment.yaml   → Deployment + Service MySQL
05-php-deployment.yaml     → Deployment + Service PHP + ConfigMap files
06-nginx-deployment.yaml   → Deployment + Service Nginx
kustomization.yaml         → Orchestration de tous les fichiers
```

## Concepts clés illustrés

### Service Discovery (DNS)

```
Dans le cluster Kubernetes, chaque Service a un DNS :

Nom court (même namespace) :
  - mysql-service
  - php-service
  - nginx-service

Nom complet (FQDN) :
  - mysql-service.php-iibs.svc.cluster.local
  - php-service.php-iibs.svc.cluster.local
  - nginx-service.php-iibs.svc.cluster.local

Format : <service-name>.<namespace>.svc.cluster.local
```

### Load Balancing

```
Service nginx-service (2 pods)
│
├─ Requête 1 → nginx-pod-1
├─ Requête 2 → nginx-pod-2
├─ Requête 3 → nginx-pod-1
└─ Requête 4 → nginx-pod-2

Algorithme : Round-robin (par défaut)
Le Service distribue automatiquement le trafic
```

### Self-Healing

```
Scénario 1 : Un pod crash
┌─────────────────────────────────┐
│ php-pod-1 (Running)             │
│ php-pod-2 (Running)             │
└─────────────────────────────────┘
         ↓ php-pod-2 crash
┌─────────────────────────────────┐
│ php-pod-1 (Running)             │
│ php-pod-2 (CrashLoopBackOff)    │
└─────────────────────────────────┘
         ↓ Kubernetes redémarre
┌─────────────────────────────────┐
│ php-pod-1 (Running)             │
│ php-pod-2 (Running) ← Nouveau!  │
└─────────────────────────────────┘

Scénario 2 : Un nœud tombe
┌─────────────┬─────────────┐
│  Node 1     │  Node 2     │
│ ─────────── │ ─────────── │
│ nginx-pod-1 │ nginx-pod-2 │
│ php-pod-1   │ php-pod-2   │
└─────────────┴─────────────┘
       ↓ Node 2 crash
┌─────────────┬─────────────┐
│  Node 1     │  Node 2 ✗   │
│ ─────────── │             │
│ nginx-pod-1 │             │
│ php-pod-1   │             │
│ nginx-pod-3 ← Recréé!     │
│ php-pod-3   ← Recréé!     │
└─────────────┴─────────────┘
```

### Rolling Update

```
Mise à jour de nginx:alpine vers nginx:1.25-alpine

Étape 1 : Démarrage
┌───────────────────────────────┐
│ nginx-pod-1 (alpine)          │
│ nginx-pod-2 (alpine)          │
└───────────────────────────────┘

Étape 2 : Création nouveau pod
┌───────────────────────────────┐
│ nginx-pod-1 (alpine)          │
│ nginx-pod-2 (alpine)          │
│ nginx-pod-3 (1.25-alpine) ←   │
└───────────────────────────────┘

Étape 3 : Suppression ancien pod
┌───────────────────────────────┐
│ nginx-pod-2 (alpine)          │
│ nginx-pod-3 (1.25-alpine)     │
└───────────────────────────────┘

Étape 4 : Création nouveau pod
┌───────────────────────────────┐
│ nginx-pod-2 (alpine)          │
│ nginx-pod-3 (1.25-alpine)     │
│ nginx-pod-4 (1.25-alpine) ←   │
└───────────────────────────────┘

Étape 5 : Suppression ancien pod
┌───────────────────────────────┐
│ nginx-pod-3 (1.25-alpine)     │
│ nginx-pod-4 (1.25-alpine)     │
└───────────────────────────────┘

Résultat : ZERO DOWNTIME !
```

## Probes (Health Checks)

### livenessProbe

```
┌────────────────────────────────┐
│        mysql-pod               │
│                                │
│  ┌──────────────────────┐     │
│  │  MySQL Process       │     │
│  │  Status: Running     │     │
│  └──────────────────────┘     │
│           ↑                    │
│           │ Ping toutes les 10s│
│  ┌────────┴─────────────────┐ │
│  │  livenessProbe           │ │
│  │  mysqladmin ping         │ │
│  │  ✓ Success               │ │
│  └──────────────────────────┘ │
└────────────────────────────────┘

Si échec 3 fois consécutives → RESTART
```

### readinessProbe

```
┌────────────────────────────────┐
│        nginx-pod               │
│                                │
│  ┌──────────────────────┐     │
│  │  Nginx Process       │     │
│  │  Status: Starting... │     │
│  └──────────────────────┘     │
│           ↑                    │
│           │ HTTP GET /         │
│  ┌────────┴─────────────────┐ │
│  │  readinessProbe          │ │
│  │  httpGet: /              │ │
│  │  ✗ Failure (503)         │ │
│  └──────────────────────────┘ │
└────────────────────────────────┘
         ↓
Service ne route PAS le trafic vers ce pod

┌────────────────────────────────┐
│        nginx-pod               │
│                                │
│  ┌──────────────────────┐     │
│  │  Nginx Process       │     │
│  │  Status: Ready!      │     │
│  └──────────────────────┘     │
│           ↑                    │
│           │ HTTP GET /         │
│  ┌────────┴─────────────────┐ │
│  │  readinessProbe          │ │
│  │  httpGet: /              │ │
│  │  ✓ Success (200 OK)      │ │
│  └──────────────────────────┘ │
└────────────────────────────────┘
         ↓
Service route le trafic vers ce pod
```

## Ressources et limites

```
┌─────────────────────────────────────────────┐
│              Nœud Kubernetes                │
│          CPU: 4 cores, RAM: 8Gi             │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │ nginx-pod                           │    │
│  │ Requests: 50m CPU, 64Mi RAM         │←─  │ Minimum garanti
│  │ Limits: 100m CPU, 128Mi RAM         │←─  │ Maximum autorisé
│  │ Current: 30m CPU, 80Mi RAM          │    │
│  └────────────────────────────────────┘    │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │ php-pod                             │    │
│  │ Requests: 100m CPU, 128Mi RAM       │    │
│  │ Limits: 200m CPU, 256Mi RAM         │    │
│  │ Current: 150m CPU, 200Mi RAM        │    │
│  └────────────────────────────────────┘    │
│                                             │
│  ┌────────────────────────────────────┐    │
│  │ mysql-pod                           │    │
│  │ Requests: 250m CPU, 256Mi RAM       │    │
│  │ Limits: 500m CPU, 512Mi RAM         │    │
│  │ Current: 300m CPU, 400Mi RAM        │    │
│  └────────────────────────────────────┘    │
│                                             │
│  Espace restant pour d'autres pods         │
│  CPU: ~2.6 cores, RAM: ~6.6Gi              │
└─────────────────────────────────────────────┘

Si un pod dépasse sa limite :
- CPU : Throttling (ralenti)
- RAM : OOMKilled (tué par le système)
```

## Résumé des avantages Kubernetes

| Feature | Docker Compose | Kubernetes |
|---------|----------------|------------|
| **Haute disponibilité** | ✗ | ✓ Pods multiples + self-healing |
| **Load balancing** | ✗ | ✓ Services avec LB intégré |
| **Auto-scaling** | ✗ | ✓ HPA (Horizontal Pod Autoscaler) |
| **Rolling updates** | ✗ | ✓ Zero-downtime deployments |
| **Self-healing** | ✗ | ✓ Redémarrage + rescheduling auto |
| **Service discovery** | Basique | ✓ DNS avancé + labels |
| **Secrets management** | ✗ | ✓ Secrets + integration vault |
| **Resource limits** | ✗ | ✓ Requests + Limits |
| **Health checks** | Basique | ✓ Liveness + Readiness probes |
| **Monitoring** | ✗ | ✓ Metrics server + Prometheus |
| **Multi-cloud** | ✗ | ✓ Portable partout |
| **Orchestration** | Machine unique | ✓ Cluster distribué |

---

Cette architecture vous donne une base solide pour comprendre comment votre application fonctionne dans Kubernetes !
