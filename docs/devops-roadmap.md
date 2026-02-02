# Roadmap DevOps Senior - Guide Complet

## Vue d'ensemble

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        PARCOURS DEVOPS ENGINEER                             │
│                                                                             │
│   JUNIOR (0-2 ans)        MID-LEVEL (2-4 ans)       SENIOR (4+ ans)        │
│   ────────────────        ───────────────────       ──────────────         │
│                                                                             │
│   Linux & Scripting       CI/CD Avancé              Architecture Cloud     │
│   Git & Versioning        Kubernetes                Design Systems         │
│   Docker Basics           IaC (Terraform)           Security & Compliance  │
│   CI/CD Basics            Monitoring/Logging        Cost Optimization      │
│   Cloud Basics            Security Basics           Team Leadership        │
│                                                                             │
│   Salaire: 35-45K€        Salaire: 45-60K€          Salaire: 60-90K€+      │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Phase 1 : Fondations (3-6 mois)

### 1.1 Linux & Administration Système

```
┌─────────────────────────────────────────────────────────────────┐
│                         LINUX                                   │
│                                                                 │
│   Essentiels :                                                  │
│   ├── Commandes de base (ls, cd, cp, mv, rm, chmod, chown)     │
│   ├── Gestion des processus (ps, top, htop, kill)              │
│   ├── Gestion des services (systemctl, journalctl)             │
│   ├── Réseau (ip, netstat, ss, curl, wget, dig, nslookup)     │
│   ├── Stockage (df, du, mount, lsblk, fdisk)                  │
│   ├── Utilisateurs & Permissions (useradd, groups, sudo)       │
│   └── SSH & Clés (ssh-keygen, ssh-copy-id, scp)               │
│                                                                 │
│   Distributions à connaître :                                   │
│   ├── Ubuntu/Debian (serveurs, conteneurs)                     │
│   ├── CentOS/RHEL/Rocky (entreprise)                           │
│   └── Alpine (conteneurs légers)                               │
└─────────────────────────────────────────────────────────────────┘
```

**Projet 1 : Serveur Web Sécurisé**
```
Objectif : Configurer un serveur Linux from scratch

Tâches :
├── Installer Ubuntu Server sur une VM
├── Configurer SSH avec clés (désactiver password auth)
├── Installer et configurer Nginx
├── Configurer un firewall (UFW ou iptables)
├── Mettre en place fail2ban
├── Configurer les logs (rsyslog)
└── Automatiser les mises à jour de sécurité

Livrable : Script d'installation automatisé
```

### 1.2 Scripting & Programmation

```
┌─────────────────────────────────────────────────────────────────┐
│                       SCRIPTING                                 │
│                                                                 │
│   Bash (Obligatoire) :                                          │
│   ├── Variables, conditions, boucles                            │
│   ├── Fonctions et arguments                                    │
│   ├── Manipulation de fichiers                                  │
│   ├── Pipes et redirections                                     │
│   ├── Expressions régulières (grep, sed, awk)                  │
│   └── Cron jobs                                                 │
│                                                                 │
│   Python (Très recommandé) :                                    │
│   ├── Syntaxe de base                                           │
│   ├── Manipulation de fichiers JSON/YAML                        │
│   ├── Requêtes HTTP (requests)                                  │
│   ├── Automatisation (paramiko, fabric)                         │
│   └── Scripts d'infrastructure                                  │
│                                                                 │
│   Bonus :                                                       │
│   ├── Go (outils cloud-native)                                  │
│   └── PowerShell (environnements Windows)                       │
└─────────────────────────────────────────────────────────────────┘
```

**Projet 2 : Boîte à Outils DevOps**
```
Objectif : Créer des scripts d'automatisation

Scripts à développer :
├── backup.sh : Sauvegarde automatique avec rotation
├── deploy.sh : Déploiement d'application avec rollback
├── monitor.sh : Vérification santé des services
├── log-analyzer.py : Analyse des logs et alertes
└── server-inventory.py : Inventaire automatique des serveurs

Livrable : Repository GitHub avec documentation
```

### 1.3 Git & Versioning

```
┌─────────────────────────────────────────────────────────────────┐
│                          GIT                                    │
│                                                                 │
│   Commandes essentielles :                                      │
│   ├── init, clone, add, commit, push, pull                     │
│   ├── branch, checkout, merge, rebase                          │
│   ├── stash, cherry-pick, reset, revert                        │
│   ├── log, diff, blame, bisect                                 │
│   └── remote, fetch, tag                                       │
│                                                                 │
│   Workflows :                                                   │
│   ├── Git Flow                                                  │
│   ├── GitHub Flow                                               │
│   ├── Trunk-based Development                                   │
│   └── Conventional Commits                                      │
│                                                                 │
│   Plateformes :                                                 │
│   ├── GitHub (+ Actions)                                        │
│   ├── GitLab (+ CI/CD)                                          │
│   └── Bitbucket (+ Pipelines)                                   │
└─────────────────────────────────────────────────────────────────┘
```

**Projet 3 : Workflow Git Complet**
```
Objectif : Maîtriser Git en équipe

Tâches :
├── Créer un repo avec branch protection
├── Implémenter Git Flow avec branches feature/develop/main
├── Configurer des templates (PR, Issues)
├── Mettre en place des hooks pre-commit
├── Gérer des conflits de merge
└── Utiliser les tags pour le versioning sémantique

Livrable : Repository avec workflow documenté
```

---

## Phase 2 : Conteneurisation (2-3 mois)

### 2.1 Docker

```
┌─────────────────────────────────────────────────────────────────┐
│                        DOCKER                                   │
│                                                                 │
│   Concepts :                                                    │
│   ├── Images vs Conteneurs                                      │
│   ├── Dockerfile & Instructions                                 │
│   ├── Layers & Cache                                            │
│   ├── Volumes & Bind mounts                                     │
│   ├── Networks (bridge, host, overlay)                         │
│   └── Docker Compose                                            │
│                                                                 │
│   Bonnes pratiques :                                            │
│   ├── Multi-stage builds                                        │
│   ├── Images minimales (Alpine, Distroless)                    │
│   ├── Non-root users                                            │
│   ├── .dockerignore                                             │
│   ├── Health checks                                             │
│   └── Security scanning (Trivy, Snyk)                          │
│                                                                 │
│   Registry :                                                    │
│   ├── Docker Hub                                                │
│   ├── GitHub Container Registry                                 │
│   ├── AWS ECR / GCP GCR / Azure ACR                            │
│   └── Harbor (self-hosted)                                      │
└─────────────────────────────────────────────────────────────────┘
```

**Projet 4 : Application Multi-Conteneurs**
```
Objectif : Conteneuriser une stack complète

Stack à déployer :
├── Frontend : React/Vue (Nginx)
├── Backend : Node.js/Python API
├── Database : PostgreSQL
├── Cache : Redis
├── Reverse Proxy : Nginx/Traefik
└── Monitoring : Prometheus + Grafana

Livrables :
├── Dockerfiles optimisés (multi-stage)
├── docker-compose.yml (dev + prod)
├── Scripts de déploiement
└── Documentation
```

### 2.2 Kubernetes (Bases)

```
┌─────────────────────────────────────────────────────────────────┐
│                     KUBERNETES BASICS                           │
│                                                                 │
│   Objets fondamentaux :                                         │
│   ├── Pods, ReplicaSets, Deployments                           │
│   ├── Services (ClusterIP, NodePort, LoadBalancer)             │
│   ├── ConfigMaps & Secrets                                      │
│   ├── Namespaces                                                │
│   └── Ingress                                                   │
│                                                                 │
│   Outils :                                                      │
│   ├── kubectl (CLI)                                             │
│   ├── Minikube / Kind / k3d (local)                            │
│   ├── Lens / k9s (UI)                                          │
│   └── Helm (package manager)                                    │
│                                                                 │
│   Managed K8s :                                                 │
│   ├── AWS EKS                                                   │
│   ├── Google GKE                                                │
│   ├── Azure AKS                                                 │
│   └── DigitalOcean DOKS                                         │
└─────────────────────────────────────────────────────────────────┘
```

**Projet 5 : Déploiement K8s**
```
Objectif : Déployer une app sur Kubernetes

Tâches :
├── Installer Minikube ou Kind
├── Créer les manifests YAML (Deployment, Service, Ingress)
├── Gérer les ConfigMaps et Secrets
├── Implémenter les health checks (liveness/readiness)
├── Configurer l'autoscaling (HPA)
└── Créer un Helm Chart

Livrable : Application déployée avec Helm
```

---

## Phase 3 : CI/CD (2-3 mois)

### 3.1 Intégration Continue (CI)

```
┌─────────────────────────────────────────────────────────────────┐
│                    CONTINUOUS INTEGRATION                       │
│                                                                 │
│   Concepts :                                                    │
│   ├── Build automation                                          │
│   ├── Tests automatisés (unit, integration, e2e)               │
│   ├── Code quality (linting, formatting)                       │
│   ├── Security scanning (SAST, SCA)                            │
│   └── Artifact management                                       │
│                                                                 │
│   Outils CI :                                                   │
│   ├── GitHub Actions ★                                          │
│   ├── GitLab CI ★                                               │
│   ├── Jenkins                                                   │
│   ├── CircleCI                                                  │
│   ├── Travis CI                                                 │
│   └── Azure DevOps                                              │
│                                                                 │
│   Tests :                                                       │
│   ├── Unit tests (Jest, PyTest, JUnit)                         │
│   ├── Integration tests                                         │
│   ├── E2E tests (Cypress, Selenium, Playwright)                │
│   └── Performance tests (k6, JMeter)                           │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Déploiement Continu (CD)

```
┌─────────────────────────────────────────────────────────────────┐
│                   CONTINUOUS DEPLOYMENT                         │
│                                                                 │
│   Stratégies de déploiement :                                   │
│   ├── Rolling Update                                            │
│   ├── Blue/Green Deployment                                     │
│   ├── Canary Deployment                                         │
│   ├── Feature Flags                                             │
│   └── A/B Testing                                               │
│                                                                 │
│   GitOps :                                                      │
│   ├── ArgoCD ★                                                  │
│   ├── Flux                                                      │
│   └── Jenkins X                                                 │
│                                                                 │
│   Environnements :                                              │
│   ├── Development                                               │
│   ├── Staging                                                   │
│   ├── Production                                                │
│   └── Feature environments (preview)                           │
└─────────────────────────────────────────────────────────────────┘
```

**Projet 6 : Pipeline CI/CD Complet**
```
Objectif : Créer un pipeline production-ready

Pipeline stages :
├── 1. Checkout code
├── 2. Install dependencies
├── 3. Lint & Format check
├── 4. Unit tests
├── 5. Build application
├── 6. Build Docker image
├── 7. Security scan (Trivy)
├── 8. Push to registry
├── 9. Deploy to staging
├── 10. Integration tests
├── 11. Manual approval
└── 12. Deploy to production

Livrables :
├── .github/workflows/ ou .gitlab-ci.yml
├── Scripts de déploiement
├── Documentation du pipeline
└── Notifications (Slack/Teams)
```

**Projet 7 : GitOps avec ArgoCD**
```
Objectif : Implémenter GitOps

Tâches :
├── Installer ArgoCD sur K8s
├── Configurer les repos Git
├── Créer les ApplicationSets
├── Implémenter le sync automatique
├── Configurer les notifications
└── Mettre en place le rollback automatique

Livrable : Infrastructure GitOps fonctionnelle
```

---

## Phase 4 : Cloud & Infrastructure as Code (3-4 mois)

### 4.1 Cloud Providers

```
┌─────────────────────────────────────────────────────────────────┐
│                      CLOUD PROVIDERS                            │
│                                                                 │
│   AWS (Leader du marché) :                                      │
│   ├── Compute : EC2, Lambda, ECS, EKS                          │
│   ├── Storage : S3, EBS, EFS                                   │
│   ├── Database : RDS, DynamoDB, ElastiCache                    │
│   ├── Network : VPC, Route53, CloudFront, ALB                  │
│   ├── Security : IAM, KMS, Secrets Manager                     │
│   └── Monitoring : CloudWatch, X-Ray                           │
│                                                                 │
│   GCP (Google Cloud) :                                          │
│   ├── Compute : GCE, Cloud Run, GKE                            │
│   ├── Storage : Cloud Storage, Persistent Disk                 │
│   ├── Database : Cloud SQL, Firestore, Bigtable               │
│   └── BigQuery, Pub/Sub, Cloud Functions                       │
│                                                                 │
│   Azure :                                                       │
│   ├── Compute : VMs, AKS, Functions                            │
│   ├── Storage : Blob Storage, Azure Files                      │
│   ├── Database : Azure SQL, CosmosDB                           │
│   └── DevOps : Azure DevOps, Azure Pipelines                   │
│                                                                 │
│   Conseil : Maîtrise 1 cloud à fond (AWS recommandé)           │
│             + notions sur les 2 autres                          │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Infrastructure as Code (IaC)

```
┌─────────────────────────────────────────────────────────────────┐
│                 INFRASTRUCTURE AS CODE                          │
│                                                                 │
│   Terraform (Multi-cloud) ★★★ :                                 │
│   ├── HCL (HashiCorp Configuration Language)                   │
│   ├── Providers (AWS, GCP, Azure, K8s)                         │
│   ├── State management (remote backend)                        │
│   ├── Modules (réutilisabilité)                                │
│   ├── Workspaces (environnements)                              │
│   └── Terragrunt (DRY)                                         │
│                                                                 │
│   Alternatives :                                                │
│   ├── Pulumi (code réel : Python, Go, TS)                      │
│   ├── AWS CloudFormation                                        │
│   ├── Azure ARM/Bicep                                           │
│   ├── Google Deployment Manager                                 │
│   └── Crossplane (K8s-native)                                  │
│                                                                 │
│   Configuration Management :                                    │
│   ├── Ansible ★★★                                               │
│   ├── Chef                                                      │
│   ├── Puppet                                                    │
│   └── SaltStack                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Projet 8 : Infrastructure AWS avec Terraform**
```
Objectif : Déployer une infrastructure complète

Architecture à créer :
┌─────────────────────────────────────────────────────────────┐
│                          VPC                                │
│  ┌─────────────────┐           ┌─────────────────┐         │
│  │  Public Subnet  │           │  Public Subnet  │         │
│  │    (AZ-1)       │           │    (AZ-2)       │         │
│  │  ┌───────────┐  │           │  ┌───────────┐  │         │
│  │  │    ALB    │  │           │  │    ALB    │  │         │
│  │  └───────────┘  │           │  └───────────┘  │         │
│  └─────────────────┘           └─────────────────┘         │
│                                                             │
│  ┌─────────────────┐           ┌─────────────────┐         │
│  │ Private Subnet  │           │ Private Subnet  │         │
│  │    (AZ-1)       │           │    (AZ-2)       │         │
│  │  ┌───────────┐  │           │  ┌───────────┐  │         │
│  │  │    EKS    │  │           │  │    EKS    │  │         │
│  │  │   Nodes   │  │           │  │   Nodes   │  │         │
│  │  └───────────┘  │           │  └───────────┘  │         │
│  └─────────────────┘           └─────────────────┘         │
│                                                             │
│  ┌─────────────────┐           ┌─────────────────┐         │
│  │   DB Subnet     │           │   DB Subnet     │         │
│  │    (AZ-1)       │           │    (AZ-2)       │         │
│  │  ┌───────────┐  │           │  ┌───────────┐  │         │
│  │  │    RDS    │◄─┼───────────┼──►│  Replica  │  │         │
│  │  │  Primary  │  │           │  │           │  │         │
│  │  └───────────┘  │           │  └───────────┘  │         │
│  └─────────────────┘           └─────────────────┘         │
└─────────────────────────────────────────────────────────────┘

Composants Terraform :
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   └── alb/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── main.tf
├── variables.tf
├── outputs.tf
└── backend.tf

Livrables :
├── Code Terraform modulaire
├── Remote state (S3 + DynamoDB)
├── Documentation
└── Pipeline CI/CD pour Terraform
```

**Projet 9 : Configuration avec Ansible**
```
Objectif : Automatiser la configuration des serveurs

Tâches :
├── Créer un inventaire dynamique (AWS)
├── Rôles Ansible :
│   ├── common (users, ssh, packages)
│   ├── docker (installation + config)
│   ├── monitoring (node_exporter)
│   └── security (firewall, fail2ban)
├── Playbooks pour différents environnements
├── Ansible Vault pour les secrets
└── Intégration avec CI/CD

Livrable : Collection Ansible réutilisable
```

---

## Phase 5 : Monitoring & Observabilité (2-3 mois)

### 5.1 Les 3 Piliers de l'Observabilité

```
┌─────────────────────────────────────────────────────────────────┐
│                    OBSERVABILITÉ                                │
│                                                                 │
│   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐          │
│   │   METRICS   │   │    LOGS     │   │   TRACES    │          │
│   │             │   │             │   │             │          │
│   │ Prometheus  │   │    Loki     │   │   Jaeger    │          │
│   │ Grafana     │   │    ELK      │   │   Zipkin    │          │
│   │ Datadog     │   │  Fluentd    │   │   Tempo     │          │
│   │             │   │             │   │             │          │
│   │ "Combien?"  │   │  "Quoi?"    │   │  "Où?"      │          │
│   └─────────────┘   └─────────────┘   └─────────────┘          │
│                                                                 │
│   Exemple de diagnostic :                                       │
│                                                                 │
│   Métrique : "Latence API = 5s" (Prometheus)                   │
│        │                                                        │
│        ▼                                                        │
│   Logs : "Timeout DB connection" (Loki)                        │
│        │                                                        │
│        ▼                                                        │
│   Trace : "Query → API → DB (4.8s)" (Jaeger)                   │
│        │                                                        │
│        ▼                                                        │
│   Solution : Optimiser la query ou ajouter un index            │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Stack de Monitoring

```
┌─────────────────────────────────────────────────────────────────┐
│                    MONITORING STACK                             │
│                                                                 │
│   Métriques :                                                   │
│   ├── Prometheus (collecte & stockage)                         │
│   ├── Grafana (visualisation)                                  │
│   ├── AlertManager (alertes)                                   │
│   ├── Node Exporter (métriques système)                        │
│   └── cAdvisor (métriques conteneurs)                          │
│                                                                 │
│   Logs :                                                        │
│   ├── Loki (stockage léger) ★                                  │
│   ├── ELK Stack (Elasticsearch, Logstash, Kibana)              │
│   ├── Fluentd / Fluent Bit (collecte)                          │
│   └── Promtail (agent Loki)                                    │
│                                                                 │
│   Traces :                                                      │
│   ├── Jaeger                                                    │
│   ├── Zipkin                                                    │
│   └── Tempo (intégré Grafana)                                  │
│                                                                 │
│   SaaS (alternatives) :                                         │
│   ├── Datadog (all-in-one)                                     │
│   ├── New Relic                                                │
│   ├── Splunk                                                   │
│   └── Elastic Cloud                                            │
└─────────────────────────────────────────────────────────────────┘
```

**Projet 10 : Stack Observabilité Complète**
```
Objectif : Déployer une stack de monitoring production-ready

Architecture :
┌─────────────────────────────────────────────────────────────┐
│                    GRAFANA (Dashboard)                      │
│                           │                                 │
│         ┌─────────────────┼─────────────────┐               │
│         │                 │                 │               │
│         ▼                 ▼                 ▼               │
│   ┌───────────┐    ┌───────────┐    ┌───────────┐          │
│   │Prometheus │    │   Loki    │    │   Tempo   │          │
│   │ (metrics) │    │  (logs)   │    │ (traces)  │          │
│   └─────┬─────┘    └─────┬─────┘    └─────┬─────┘          │
│         │                │                │                 │
│         ▼                ▼                ▼                 │
│   ┌───────────┐    ┌───────────┐    ┌───────────┐          │
│   │  Node     │    │ Promtail  │    │   OTEL    │          │
│   │ Exporter  │    │           │    │ Collector │          │
│   └───────────┘    └───────────┘    └───────────┘          │
│                                                             │
│   AlertManager ──► Slack/PagerDuty/Email                   │
└─────────────────────────────────────────────────────────────┘

Tâches :
├── Déployer Prometheus + Grafana sur K8s
├── Configurer les exporters
├── Créer des dashboards personnalisés
├── Configurer les alertes (SLI/SLO)
├── Intégrer Loki pour les logs
├── Mettre en place le tracing distribué
└── Configurer les notifications

Livrables :
├── Helm charts / Manifests K8s
├── Dashboards Grafana (JSON)
├── Règles d'alertes
└── Runbooks
```

---

## Phase 6 : Sécurité DevSecOps (2-3 mois)

### 6.1 Security as Code

```
┌─────────────────────────────────────────────────────────────────┐
│                       DEVSECOPS                                 │
│                                                                 │
│   Shift Left Security :                                         │
│                                                                 │
│   ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐        │
│   │Code │─►│Build│─►│Test │─►│Deploy│─►│Run  │─►│Monitor│       │
│   └──┬──┘  └──┬──┘  └──┬──┘  └──┬──┘  └──┬──┘  └──┬──┘        │
│      │        │        │        │        │        │            │
│      ▼        ▼        ▼        ▼        ▼        ▼            │
│   ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐        │
│   │SAST │  │SCA  │  │DAST │  │Image│  │RASP │  │SIEM │        │
│   │     │  │     │  │     │  │Scan │  │     │  │     │        │
│   └─────┘  └─────┘  └─────┘  └─────┘  └─────┘  └─────┘        │
│                                                                 │
│   SAST : Static Application Security Testing                    │
│   SCA  : Software Composition Analysis                          │
│   DAST : Dynamic Application Security Testing                   │
│   RASP : Runtime Application Self-Protection                    │
│   SIEM : Security Information & Event Management                │
└─────────────────────────────────────────────────────────────────┘
```

### 6.2 Outils de Sécurité

```
┌─────────────────────────────────────────────────────────────────┐
│                    SECURITY TOOLS                               │
│                                                                 │
│   Scan de Code :                                                │
│   ├── SonarQube (qualité + sécurité)                           │
│   ├── Snyk (vulnérabilités)                                    │
│   ├── Semgrep (SAST)                                           │
│   └── GitLeaks (secrets dans le code)                          │
│                                                                 │
│   Scan de Conteneurs :                                          │
│   ├── Trivy ★ (images, IaC, secrets)                           │
│   ├── Clair                                                     │
│   ├── Anchore                                                   │
│   └── Snyk Container                                            │
│                                                                 │
│   Sécurité Kubernetes :                                         │
│   ├── OPA/Gatekeeper (policies)                                │
│   ├── Falco (runtime security)                                 │
│   ├── kube-bench (CIS benchmark)                               │
│   ├── Kyverno (policies)                                       │
│   └── Sealed Secrets                                           │
│                                                                 │
│   Gestion des Secrets :                                         │
│   ├── HashiCorp Vault ★                                        │
│   ├── AWS Secrets Manager                                       │
│   ├── Azure Key Vault                                           │
│   └── External Secrets Operator                                 │
│                                                                 │
│   Compliance :                                                  │
│   ├── Checkov (IaC security)                                   │
│   ├── tfsec (Terraform)                                        │
│   └── Prowler (AWS security)                                   │
└─────────────────────────────────────────────────────────────────┘
```

**Projet 11 : Pipeline DevSecOps**
```
Objectif : Intégrer la sécurité dans le CI/CD

Pipeline sécurisé :
┌─────────────────────────────────────────────────────────────┐
│                    DEVSECOPS PIPELINE                       │
│                                                             │
│  ┌──────────┐                                               │
│  │  Commit  │                                               │
│  └────┬─────┘                                               │
│       │                                                     │
│       ▼                                                     │
│  ┌──────────┐  Secrets detection (GitLeaks)                │
│  │Pre-commit│  Lint + Format                                │
│  └────┬─────┘                                               │
│       │                                                     │
│       ▼                                                     │
│  ┌──────────┐  SAST (SonarQube, Semgrep)                   │
│  │   SAST   │  Dependencies check (Snyk)                   │
│  └────┬─────┘                                               │
│       │                                                     │
│       ▼                                                     │
│  ┌──────────┐  Unit tests + Coverage                       │
│  │  Tests   │                                               │
│  └────┬─────┘                                               │
│       │                                                     │
│       ▼                                                     │
│  ┌──────────┐  Build image                                 │
│  │  Build   │  Image scan (Trivy)                          │
│  └────┬─────┘  Sign image (Cosign)                         │
│       │                                                     │
│       ▼                                                     │
│  ┌──────────┐  IaC scan (Checkov)                          │
│  │ IaC Scan │  K8s policies (OPA)                          │
│  └────┬─────┘                                               │
│       │                                                     │
│       ▼                                                     │
│  ┌──────────┐  Deploy to staging                           │
│  │  Deploy  │  DAST (OWASP ZAP)                            │
│  └────┬─────┘                                               │
│       │                                                     │
│       ▼                                                     │
│  ┌──────────┐  Security gate                               │
│  │Production│  Monitoring (Falco)                          │
│  └──────────┘                                               │
└─────────────────────────────────────────────────────────────┘

Livrables :
├── Pipeline CI/CD avec gates de sécurité
├── Policies OPA/Kyverno
├── Configuration Vault
└── Security dashboard
```

---

## Phase 7 : Compétences Senior (Continu)

### 7.1 Architecture & Design

```
┌─────────────────────────────────────────────────────────────────┐
│                 COMPÉTENCES SENIOR                              │
│                                                                 │
│   Architecture :                                                │
│   ├── Microservices patterns                                    │
│   ├── Event-driven architecture                                 │
│   ├── Service mesh (Istio, Linkerd)                            │
│   ├── API Gateway patterns                                      │
│   ├── Caching strategies                                        │
│   └── Database patterns (CQRS, Event Sourcing)                 │
│                                                                 │
│   Reliability :                                                 │
│   ├── SLI/SLO/SLA definition                                   │
│   ├── Error budgets                                             │
│   ├── Chaos engineering (Chaos Monkey, Litmus)                 │
│   ├── Disaster recovery                                         │
│   ├── Multi-region deployment                                   │
│   └── Capacity planning                                         │
│                                                                 │
│   FinOps :                                                      │
│   ├── Cost optimization                                         │
│   ├── Reserved instances / Spot instances                      │
│   ├── Right-sizing                                              │
│   ├── Tagging strategy                                          │
│   └── Cost allocation                                           │
│                                                                 │
│   Leadership :                                                  │
│   ├── Technical documentation                                   │
│   ├── Architecture Decision Records (ADR)                      │
│   ├── Mentoring juniors                                         │
│   ├── Incident management                                       │
│   └── Post-mortems (blameless)                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Projet 12 : Plateforme DevOps Complète**
```
Objectif : Construire une Internal Developer Platform (IDP)

Architecture finale :
┌─────────────────────────────────────────────────────────────────┐
│                  INTERNAL DEVELOPER PLATFORM                    │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                    DEVELOPER PORTAL                       │  │
│  │                    (Backstage.io)                         │  │
│  └───────────────────────────────────────────────────────────┘  │
│                              │                                  │
│       ┌──────────────────────┼──────────────────────┐          │
│       │                      │                      │          │
│       ▼                      ▼                      ▼          │
│  ┌─────────┐           ┌─────────┐           ┌─────────┐       │
│  │  GitOps │           │   IaC   │           │   CI/CD │       │
│  │ (ArgoCD)│           │(Terraform)          │(GitHub) │       │
│  └────┬────┘           └────┬────┘           └────┬────┘       │
│       │                     │                     │            │
│       └─────────────────────┼─────────────────────┘            │
│                             │                                  │
│                             ▼                                  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                     KUBERNETES                            │  │
│  │  ┌─────────────────────────────────────────────────────┐  │  │
│  │  │                   Service Mesh                      │  │  │
│  │  │                     (Istio)                         │  │  │
│  │  │                                                     │  │  │
│  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐            │  │  │
│  │  │  │  App A  │  │  App B  │  │  App C  │            │  │  │
│  │  │  └─────────┘  └─────────┘  └─────────┘            │  │  │
│  │  └─────────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────────┘  │
│                             │                                  │
│       ┌─────────────────────┼─────────────────────┐            │
│       │                     │                     │            │
│       ▼                     ▼                     ▼            │
│  ┌─────────┐           ┌─────────┐           ┌─────────┐       │
│  │Monitoring│          │  Logs   │           │Security │       │
│  │(Grafana)│           │ (Loki) │           │ (Vault) │       │
│  └─────────┘           └─────────┘           └─────────┘       │
└─────────────────────────────────────────────────────────────────┘

Composants :
├── Kubernetes multi-cluster (EKS)
├── GitOps avec ArgoCD
├── Service Mesh (Istio)
├── Observabilité (Prometheus, Grafana, Loki, Tempo)
├── Security (Vault, OPA, Falco)
├── Developer Portal (Backstage)
├── Cost Management
└── Documentation complète

Ce projet = Portfolio pour postuler Senior DevOps
```

---

## Certifications Recommandées

```
┌─────────────────────────────────────────────────────────────────┐
│                     CERTIFICATIONS                              │
│                                                                 │
│   Kubernetes :                                                  │
│   ├── CKA (Certified Kubernetes Administrator) ★★★             │
│   ├── CKAD (Certified Kubernetes Application Developer)        │
│   └── CKS (Certified Kubernetes Security Specialist)           │
│                                                                 │
│   AWS :                                                         │
│   ├── AWS Solutions Architect Associate ★★★                    │
│   ├── AWS SysOps Administrator Associate                       │
│   ├── AWS DevOps Engineer Professional                         │
│   └── AWS Security Specialty                                   │
│                                                                 │
│   GCP :                                                         │
│   ├── Google Associate Cloud Engineer                          │
│   └── Google Professional Cloud DevOps Engineer                │
│                                                                 │
│   Azure :                                                       │
│   ├── AZ-104 Azure Administrator                               │
│   └── AZ-400 Azure DevOps Engineer Expert                      │
│                                                                 │
│   HashiCorp :                                                   │
│   ├── Terraform Associate ★★                                   │
│   └── Vault Associate                                          │
│                                                                 │
│   Linux :                                                       │
│   └── LFCS (Linux Foundation Certified SysAdmin)               │
│                                                                 │
│   Ordre recommandé :                                            │
│   1. AWS SAA → 2. CKA → 3. Terraform → 4. CKS                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Timeline Recommandée

```
┌─────────────────────────────────────────────────────────────────┐
│                    TIMELINE (18-24 mois)                        │
│                                                                 │
│   Mois 1-3 : Fondations                                         │
│   ├── Linux administration                                      │
│   ├── Scripting (Bash + Python)                                │
│   └── Git avancé                                                │
│                                                                 │
│   Mois 4-6 : Conteneurisation                                   │
│   ├── Docker (maîtrise complète)                               │
│   └── Kubernetes (bases)                                        │
│                                                                 │
│   Mois 7-9 : CI/CD                                              │
│   ├── GitHub Actions / GitLab CI                               │
│   ├── Pipelines complets                                        │
│   └── GitOps (ArgoCD)                                           │
│                                                                 │
│   Mois 10-13 : Cloud & IaC                                      │
│   ├── AWS (services principaux)                                │
│   ├── Terraform                                                 │
│   └── Certification AWS SAA                                     │
│                                                                 │
│   Mois 14-16 : Monitoring & Observabilité                       │
│   ├── Prometheus + Grafana                                      │
│   ├── Logging (Loki/ELK)                                       │
│   └── Certification CKA                                         │
│                                                                 │
│   Mois 17-20 : Sécurité                                         │
│   ├── DevSecOps                                                 │
│   ├── Vault                                                     │
│   └── Certification Terraform                                   │
│                                                                 │
│   Mois 21-24 : Advanced                                         │
│   ├── Service Mesh                                              │
│   ├── Chaos Engineering                                         │
│   ├── Platform Engineering                                      │
│   └── Certification CKS                                         │
│                                                                 │
│   Après 24 mois : Tu es prêt pour un poste Senior !            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Ressources d'Apprentissage

### Plateformes

| Plateforme | Contenu | Prix |
|------------|---------|------|
| KodeKloud | K8s, Docker, Ansible, Terraform | ~15€/mois |
| A Cloud Guru | AWS, GCP, Azure, DevOps | ~35€/mois |
| Udemy | Cours variés | 10-15€/cours |
| Linux Academy | Linux, Cloud | Inclus ACG |
| Pluralsight | Tout | ~30€/mois |

### Labs Pratiques

| Plateforme | Type | Prix |
|------------|------|------|
| KillerCoda | K8s, Linux, Docker | Gratuit |
| Play with Docker | Docker | Gratuit |
| Play with K8s | Kubernetes | Gratuit |
| Katacoda | DevOps | Gratuit |
| AWS Free Tier | AWS | Gratuit (limité) |
| GCP Free Tier | GCP | Gratuit (limité) |

### Livres Recommandés

```
1. "The Phoenix Project" - Gene Kim (DevOps culture)
2. "The DevOps Handbook" - Gene Kim (practices)
3. "Site Reliability Engineering" - Google (SRE)
4. "Kubernetes Up & Running" - O'Reilly
5. "Terraform Up & Running" - O'Reilly
6. "Docker Deep Dive" - Nigel Poulton
7. "The Site Reliability Workbook" - Google
8. "Accelerate" - Nicole Forsgren (metrics)
```

### Blogs & Newsletters

```
├── DevOps Weekly (newsletter)
├── CNCF Blog
├── HashiCorp Blog
├── AWS Blog
├── Kubernetes Blog
├── The New Stack
└── InfoQ DevOps
```

### YouTube Channels

```
├── TechWorld with Nana ★★★
├── NetworkChuck
├── KodeKloud
├── That DevOps Guy
├── DevOps Toolkit
└── IBM Technology
```

---

## Checklist Final

```
┌─────────────────────────────────────────────────────────────────┐
│              CHECKLIST DEVOPS SENIOR                            │
│                                                                 │
│   Fondations :                                                  │
│   [ ] Linux administration avancée                              │
│   [ ] Scripting Bash fluent                                     │
│   [ ] Python pour l'automatisation                              │
│   [ ] Git workflows maîtrisés                                   │
│                                                                 │
│   Conteneurisation :                                            │
│   [ ] Docker (build, optimize, secure)                         │
│   [ ] Kubernetes (deploy, manage, troubleshoot)                │
│   [ ] Helm charts                                               │
│                                                                 │
│   CI/CD :                                                       │
│   [ ] Pipelines production-ready                               │
│   [ ] GitOps (ArgoCD/Flux)                                     │
│   [ ] Testing strategies                                        │
│                                                                 │
│   Cloud & IaC :                                                 │
│   [ ] AWS (ou GCP/Azure) maîtrisé                              │
│   [ ] Terraform modules réutilisables                          │
│   [ ] Ansible playbooks                                         │
│                                                                 │
│   Observabilité :                                               │
│   [ ] Prometheus + Grafana                                      │
│   [ ] Centralized logging                                       │
│   [ ] Distributed tracing                                       │
│   [ ] Alerting & On-call                                        │
│                                                                 │
│   Sécurité :                                                    │
│   [ ] DevSecOps pipeline                                        │
│   [ ] Secrets management (Vault)                               │
│   [ ] Container security                                        │
│   [ ] Compliance as Code                                        │
│                                                                 │
│   Soft Skills :                                                 │
│   [ ] Documentation technique                                   │
│   [ ] Incident management                                       │
│   [ ] Mentoring                                                 │
│   [ ] Communication avec les devs                               │
│                                                                 │
│   Certifications :                                              │
│   [ ] AWS Solutions Architect                                   │
│   [ ] CKA (Kubernetes)                                          │
│   [ ] Terraform Associate                                       │
│                                                                 │
│   Portfolio :                                                   │
│   [ ] GitHub avec projets documentés                           │
│   [ ] Blog technique (optionnel mais +++)                      │
│   [ ] Contributions open source                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

**Bon courage dans ton parcours DevOps !**

Le plus important : **PRATIQUER**. La théorie c'est bien, mais c'est en faisant des projets que tu apprends vraiment. Chaque projet de cette roadmap te rapproche du niveau Senior.
