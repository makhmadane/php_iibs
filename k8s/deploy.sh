#!/bin/bash
# ====================================
# Script de déploiement automatique pour Kubernetes
# ====================================
# Ce script simplifie le déploiement de l'application sur Kubernetes
#
# Usage:
#   ./deploy.sh deploy    # Déployer l'application
#   ./deploy.sh delete    # Supprimer l'application
#   ./deploy.sh status    # Voir le statut
#   ./deploy.sh logs      # Voir les logs
#   ./deploy.sh access    # Obtenir l'URL d'accès
# ====================================

set -e  # Arrêter en cas d'erreur

NAMESPACE="php-iibs"
COLOR_GREEN='\033[0;32m'
COLOR_RED='\033[0;31m'
COLOR_YELLOW='\033[1;33m'
COLOR_NC='\033[0m' # No Color

# Fonction pour afficher un message de succès
success() {
    echo -e "${COLOR_GREEN}✓ $1${COLOR_NC}"
}

# Fonction pour afficher un message d'erreur
error() {
    echo -e "${COLOR_RED}✗ $1${COLOR_NC}"
}

# Fonction pour afficher un message d'info
info() {
    echo -e "${COLOR_YELLOW}ℹ $1${COLOR_NC}"
}

# Vérifier que kubectl est installé
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        error "kubectl n'est pas installé. Veuillez l'installer d'abord."
        exit 1
    fi
    success "kubectl est installé"
}

# Vérifier la connexion au cluster
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        error "Impossible de se connecter au cluster Kubernetes."
        error "Assurez-vous que minikube/docker-desktop est démarré."
        exit 1
    fi
    success "Connexion au cluster Kubernetes réussie"
}

# Déployer l'application
deploy() {
    info "Déploiement de l'application php-iibs sur Kubernetes..."
    echo ""

    check_kubectl
    check_cluster

    # Déployer avec Kustomize
    info "Application des manifestes Kubernetes..."
    kubectl apply -k "$(dirname "$0")"

    echo ""
    success "Déploiement terminé !"
    echo ""

    info "Attente que tous les pods soient prêts (peut prendre 1-2 minutes)..."
    kubectl wait --for=condition=ready pod -l app=mysql -n $NAMESPACE --timeout=120s || true
    kubectl wait --for=condition=ready pod -l app=php -n $NAMESPACE --timeout=120s || true
    kubectl wait --for=condition=ready pod -l app=nginx -n $NAMESPACE --timeout=120s || true

    echo ""
    success "Tous les pods sont prêts !"
    echo ""

    # Afficher le statut
    status
}

# Supprimer l'application
delete() {
    info "Suppression de l'application php-iibs..."

    kubectl delete -k "$(dirname "$0")" || true

    success "Application supprimée"
}

# Afficher le statut
status() {
    info "Statut de l'application php-iibs :"
    echo ""

    echo "=== PODS ==="
    kubectl get pods -n $NAMESPACE -o wide
    echo ""

    echo "=== SERVICES ==="
    kubectl get services -n $NAMESPACE
    echo ""

    echo "=== DEPLOYMENTS ==="
    kubectl get deployments -n $NAMESPACE
    echo ""

    echo "=== PVC ==="
    kubectl get pvc -n $NAMESPACE
    echo ""
}

# Afficher les logs
logs() {
    info "Logs de l'application :"
    echo ""

    echo "=== NGINX LOGS ==="
    kubectl logs -l app=nginx -n $NAMESPACE --tail=20
    echo ""

    echo "=== PHP LOGS ==="
    kubectl logs -l app=php -n $NAMESPACE --tail=20
    echo ""

    echo "=== MYSQL LOGS ==="
    kubectl logs -l app=mysql -n $NAMESPACE --tail=20
    echo ""
}

# Obtenir l'URL d'accès
access() {
    info "Obtention de l'URL d'accès..."
    echo ""

    # Détecter le type de cluster
    if command -v minikube &> /dev/null && minikube status &> /dev/null; then
        info "Cluster Minikube détecté"
        MINIKUBE_IP=$(minikube ip)
        echo ""
        success "Accédez à l'application via :"
        echo "  http://$MINIKUBE_IP:30080"
        echo ""
        info "Ou lancez : minikube service nginx-service -n $NAMESPACE"
    else
        info "Cluster standard détecté"
        NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
        echo ""
        success "Accédez à l'application via :"
        echo "  http://$NODE_IP:30080"
        echo "  ou http://localhost:30080 (si local)"
    fi
    echo ""
}

# Fonction d'aide
help() {
    echo "Usage: $0 {deploy|delete|status|logs|access|help}"
    echo ""
    echo "Commandes :"
    echo "  deploy  - Déployer l'application sur Kubernetes"
    echo "  delete  - Supprimer l'application de Kubernetes"
    echo "  status  - Afficher le statut de l'application"
    echo "  logs    - Afficher les logs de l'application"
    echo "  access  - Obtenir l'URL pour accéder à l'application"
    echo "  help    - Afficher cette aide"
    echo ""
}

# Menu principal
case "${1:-}" in
    deploy)
        deploy
        ;;
    delete)
        delete
        ;;
    status)
        status
        ;;
    logs)
        logs
        ;;
    access)
        access
        ;;
    help|--help|-h)
        help
        ;;
    *)
        error "Commande invalide : ${1:-}"
        echo ""
        help
        exit 1
        ;;
esac
