# ====================================
# Script de déploiement automatique pour Kubernetes (Windows PowerShell)
# ====================================
# Ce script simplifie le déploiement de l'application sur Kubernetes
#
# Usage:
#   .\deploy.ps1 deploy    # Déployer l'application
#   .\deploy.ps1 delete    # Supprimer l'application
#   .\deploy.ps1 status    # Voir le statut
#   .\deploy.ps1 logs      # Voir les logs
#   .\deploy.ps1 access    # Obtenir l'URL d'accès
# ====================================

param(
    [Parameter(Position=0)]
    [string]$Command = "help"
)

$NAMESPACE = "php-iibs"
$ErrorActionPreference = "Stop"

# Fonctions de couleur
function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Yellow
}

# Vérifier que kubectl est installé
function Test-Kubectl {
    try {
        $null = kubectl version --client 2>$null
        Write-Success "kubectl est installé"
        return $true
    } catch {
        Write-Error-Custom "kubectl n'est pas installé. Veuillez l'installer d'abord."
        return $false
    }
}

# Vérifier la connexion au cluster
function Test-Cluster {
    try {
        $null = kubectl cluster-info 2>$null
        Write-Success "Connexion au cluster Kubernetes réussie"
        return $true
    } catch {
        Write-Error-Custom "Impossible de se connecter au cluster Kubernetes."
        Write-Error-Custom "Assurez-vous que minikube/docker-desktop est démarré."
        return $false
    }
}

# Déployer l'application
function Deploy-Application {
    Write-Info "Déploiement de l'application php-iibs sur Kubernetes..."
    Write-Host ""

    if (-not (Test-Kubectl)) { exit 1 }
    if (-not (Test-Cluster)) { exit 1 }

    # Déployer avec Kustomize
    Write-Info "Application des manifestes Kubernetes..."
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    kubectl apply -k $scriptDir

    Write-Host ""
    Write-Success "Déploiement terminé !"
    Write-Host ""

    Write-Info "Attente que tous les pods soient prêts (peut prendre 1-2 minutes)..."
    kubectl wait --for=condition=ready pod -l app=mysql -n $NAMESPACE --timeout=120s 2>$null
    kubectl wait --for=condition=ready pod -l app=php -n $NAMESPACE --timeout=120s 2>$null
    kubectl wait --for=condition=ready pod -l app=nginx -n $NAMESPACE --timeout=120s 2>$null

    Write-Host ""
    Write-Success "Tous les pods sont prêts !"
    Write-Host ""

    # Afficher le statut
    Get-Status
}

# Supprimer l'application
function Remove-Application {
    Write-Info "Suppression de l'application php-iibs..."

    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    kubectl delete -k $scriptDir 2>$null

    Write-Success "Application supprimée"
}

# Afficher le statut
function Get-Status {
    Write-Info "Statut de l'application php-iibs :"
    Write-Host ""

    Write-Host "=== PODS ===" -ForegroundColor Cyan
    kubectl get pods -n $NAMESPACE -o wide
    Write-Host ""

    Write-Host "=== SERVICES ===" -ForegroundColor Cyan
    kubectl get services -n $NAMESPACE
    Write-Host ""

    Write-Host "=== DEPLOYMENTS ===" -ForegroundColor Cyan
    kubectl get deployments -n $NAMESPACE
    Write-Host ""

    Write-Host "=== PVC ===" -ForegroundColor Cyan
    kubectl get pvc -n $NAMESPACE
    Write-Host ""
}

# Afficher les logs
function Get-Logs {
    Write-Info "Logs de l'application :"
    Write-Host ""

    Write-Host "=== NGINX LOGS ===" -ForegroundColor Cyan
    kubectl logs -l app=nginx -n $NAMESPACE --tail=20 2>$null
    Write-Host ""

    Write-Host "=== PHP LOGS ===" -ForegroundColor Cyan
    kubectl logs -l app=php -n $NAMESPACE --tail=20 2>$null
    Write-Host ""

    Write-Host "=== MYSQL LOGS ===" -ForegroundColor Cyan
    kubectl logs -l app=mysql -n $NAMESPACE --tail=20 2>$null
    Write-Host ""
}

# Obtenir l'URL d'accès
function Get-Access {
    Write-Info "Obtention de l'URL d'accès..."
    Write-Host ""

    # Détecter le type de cluster
    $minikubeExists = Get-Command minikube -ErrorAction SilentlyContinue
    if ($minikubeExists) {
        try {
            $null = minikube status 2>$null
            Write-Info "Cluster Minikube détecté"
            $minikubeIP = minikube ip
            Write-Host ""
            Write-Success "Accédez à l'application via :"
            Write-Host "  http://${minikubeIP}:30080" -ForegroundColor White
            Write-Host ""
            Write-Info "Ou lancez : minikube service nginx-service -n $NAMESPACE"
        } catch {
            Write-Info "Cluster standard détecté"
            Write-Host ""
            Write-Success "Accédez à l'application via :"
            Write-Host "  http://localhost:30080" -ForegroundColor White
        }
    } else {
        Write-Info "Cluster standard détecté"
        Write-Host ""
        Write-Success "Accédez à l'application via :"
        Write-Host "  http://localhost:30080" -ForegroundColor White
    }
    Write-Host ""
}

# Fonction d'aide
function Show-Help {
    Write-Host "Usage: .\deploy.ps1 {deploy|delete|status|logs|access|help}"
    Write-Host ""
    Write-Host "Commandes :"
    Write-Host "  deploy  - Déployer l'application sur Kubernetes"
    Write-Host "  delete  - Supprimer l'application de Kubernetes"
    Write-Host "  status  - Afficher le statut de l'application"
    Write-Host "  logs    - Afficher les logs de l'application"
    Write-Host "  access  - Obtenir l'URL pour accéder à l'application"
    Write-Host "  help    - Afficher cette aide"
    Write-Host ""
}

# Menu principal
switch ($Command.ToLower()) {
    "deploy" {
        Deploy-Application
    }
    "delete" {
        Remove-Application
    }
    "status" {
        Get-Status
    }
    "logs" {
        Get-Logs
    }
    "access" {
        Get-Access
    }
    "help" {
        Show-Help
    }
    default {
        Write-Error-Custom "Commande invalide : $Command"
        Write-Host ""
        Show-Help
        exit 1
    }
}
