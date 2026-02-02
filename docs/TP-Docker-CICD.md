# Série de Travaux Pratiques : Docker jusqu'au CI/CD

## Introduction

Cette série de TP vous guidera progressivement de la découverte de Docker jusqu'à la mise en place d'un pipeline CI/CD complet. Chaque TP s'appuie sur le précédent.

---

## TP 1 : Découverte de Docker - Les Bases

### Objectifs
- Comprendre ce qu'est un conteneur
- Manipuler les commandes Docker de base
- Lancer ses premiers conteneurs

### Prérequis
- Docker Desktop installé
- Terminal/PowerShell

### Exercice 1.1 : Vérifier l'installation
```bash
# Vérifier la version de Docker
docker --version

# Vérifier que Docker fonctionne
docker info

# Afficher l'aide
docker --help
```

### Exercice 1.2 : Premier conteneur
```bash
# Lancer un conteneur Hello World
docker run hello-world

# Comprendre ce qui s'est passé :
# 1. Docker a cherché l'image "hello-world" localement
# 2. Ne l'ayant pas trouvée, il l'a téléchargée depuis Docker Hub
# 3. Il a créé un conteneur à partir de cette image
# 4. Il a exécuté le conteneur qui affiche un message
```

### Exercice 1.3 : Conteneur interactif
```bash
# Lancer un conteneur Ubuntu en mode interactif
docker run -it ubuntu bash

# À l'intérieur du conteneur, essayez :
cat /etc/os-release
ls /
exit

# Lancer un conteneur Alpine (plus léger)
docker run -it alpine sh
cat /etc/os-release
exit
```

### Exercice 1.4 : Gestion des conteneurs
```bash
# Lister les conteneurs en cours d'exécution
docker ps

# Lister TOUS les conteneurs (même arrêtés)
docker ps -a

# Lancer un conteneur en arrière-plan (détaché)
docker run -d --name mon-nginx nginx

# Vérifier qu'il tourne
docker ps

# Voir les logs
docker logs mon-nginx

# Arrêter le conteneur
docker stop mon-nginx

# Supprimer le conteneur
docker rm mon-nginx

# Supprimer tous les conteneurs arrêtés
docker container prune
```

### Exercice 1.5 : Gestion des images
```bash
# Lister les images locales
docker images

# Télécharger une image sans lancer de conteneur
docker pull php:8.2

# Supprimer une image
docker rmi hello-world

# Supprimer les images non utilisées
docker image prune
```

### Quiz TP1
1. Quelle est la différence entre une image et un conteneur ?
2. Que fait l'option `-d` dans `docker run -d` ?
3. Que fait l'option `-it` dans `docker run -it` ?
4. Comment voir les logs d'un conteneur nommé "app" ?

---

## TP 2 : Les Volumes et Ports

### Objectifs
- Comprendre le mapping de ports
- Utiliser les volumes pour persister les données
- Comprendre l'isolation réseau

### Exercice 2.1 : Mapping de ports
```bash
# Lancer Nginx sur le port 8080 de votre machine
docker run -d --name web -p 8080:80 nginx

# Tester dans votre navigateur : http://localhost:8080

# Voir le mapping de ports
docker port web

# Arrêter et supprimer
docker stop web && docker rm web
```

### Exercice 2.2 : Volumes - Montage d'un dossier local
```bash
# Créer un dossier de travail
mkdir tp-docker
cd tp-docker

# Créer un fichier HTML
echo "<h1>Hello Docker!</h1>" > index.html

# Monter ce dossier dans un conteneur Nginx
docker run -d --name web-local \
  -p 8080:80 \
  -v ${PWD}:/usr/share/nginx/html \
  nginx

# Sur Windows PowerShell, utilisez :
docker run -d --name web-local -p 8080:80 -v ${PWD}:/usr/share/nginx/html nginx

# Modifier index.html et rafraîchir le navigateur
# Les changements sont instantanés !

# Nettoyage
docker stop web-local && docker rm web-local
```

### Exercice 2.3 : Volumes nommés (persistance)
```bash
# Créer un volume nommé
docker volume create mes-donnees

# Lister les volumes
docker volume ls

# Utiliser ce volume avec MySQL
docker run -d --name mysql-test \
  -e MYSQL_ROOT_PASSWORD=secret \
  -v mes-donnees:/var/lib/mysql \
  mysql:8

# Créer une base de données
docker exec -it mysql-test mysql -uroot -psecret -e "CREATE DATABASE test_db;"

# Vérifier
docker exec -it mysql-test mysql -uroot -psecret -e "SHOW DATABASES;"

# Arrêter et supprimer le conteneur
docker stop mysql-test && docker rm mysql-test

# Relancer avec le même volume - les données sont préservées !
docker run -d --name mysql-test2 \
  -e MYSQL_ROOT_PASSWORD=secret \
  -v mes-donnees:/var/lib/mysql \
  mysql:8

# Attendre quelques secondes puis vérifier
docker exec -it mysql-test2 mysql -uroot -psecret -e "SHOW DATABASES;"
# La base test_db existe toujours !

# Nettoyage
docker stop mysql-test2 && docker rm mysql-test2
docker volume rm mes-donnees
```

### Exercice 2.4 : Variables d'environnement
```bash
# Passer des variables d'environnement
docker run -d --name db \
  -e MYSQL_ROOT_PASSWORD=monpassword \
  -e MYSQL_DATABASE=mabase \
  -e MYSQL_USER=monuser \
  -e MYSQL_PASSWORD=userpass \
  mysql:8

# Vérifier les variables
docker exec db env | grep MYSQL

# Nettoyage
docker stop db && docker rm db
```

### Quiz TP2
1. Que signifie `-p 8080:80` ?
2. Quelle est la différence entre un volume nommé et un montage de dossier ?
3. Comment passer une variable d'environnement à un conteneur ?

---

## TP 3 : Créer ses propres images avec Dockerfile

### Objectifs
- Comprendre la syntaxe d'un Dockerfile
- Construire des images personnalisées
- Optimiser ses images

### Exercice 3.1 : Premier Dockerfile
```bash
# Créer un dossier pour le projet
mkdir mon-app-php
cd mon-app-php

# Créer un fichier PHP simple
```

Créez `index.php` :
```php
<?php
echo "<h1>Mon Application PHP</h1>";
echo "<p>Date: " . date('Y-m-d H:i:s') . "</p>";
echo "<p>Serveur: " . gethostname() . "</p>";
phpinfo();
?>
```

Créez `Dockerfile` :
```dockerfile
# Image de base
FROM php:8.2-apache

# Métadonnées
LABEL maintainer="votre@email.com"
LABEL description="Mon application PHP"

# Copier les fichiers de l'application
COPY index.php /var/www/html/

# Exposer le port 80
EXPOSE 80

# La commande par défaut est déjà définie dans l'image de base
```

```bash
# Construire l'image
docker build -t mon-app-php:v1 .

# Vérifier que l'image existe
docker images | grep mon-app-php

# Lancer un conteneur
docker run -d --name app -p 8080:80 mon-app-php:v1

# Tester : http://localhost:8080

# Nettoyage
docker stop app && docker rm app
```

### Exercice 3.2 : Dockerfile avec PHP-FPM (comme dans votre projet)
```bash
mkdir php-fpm-app
cd php-fpm-app
```

Créez `Dockerfile` :
```dockerfile
FROM php:8.2-fpm

# Installer les extensions PHP
RUN docker-php-ext-install pdo pdo_mysql mysqli

# Définir le répertoire de travail
WORKDIR /var/www/html

# Copier les fichiers (on peut aussi monter un volume)
COPY . .

# Exposer le port FPM
EXPOSE 9000

# Commande par défaut (déjà définie dans l'image de base)
CMD ["php-fpm"]
```

```bash
# Créer un fichier PHP
echo "<?php echo 'Hello from PHP-FPM!'; ?>" > index.php

# Construire
docker build -t php-fpm-custom:v1 .

# Voir les couches de l'image
docker history php-fpm-custom:v1
```

### Exercice 3.3 : Optimisation - Multi-stage build
```bash
mkdir app-optimized
cd app-optimized
```

Créez `Dockerfile` :
```dockerfile
# Étape 1 : Construction (si nécessaire pour installer des dépendances)
FROM php:8.2-fpm AS builder

# Installer Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /app
# COPY composer.json composer.lock ./
# RUN composer install --no-dev --optimize-autoloader

# Étape 2 : Image finale légère
FROM php:8.2-fpm-alpine

# Installer les extensions nécessaires
RUN docker-php-ext-install pdo pdo_mysql

WORKDIR /var/www/html

# Copier depuis l'étape de build (si nécessaire)
# COPY --from=builder /app/vendor ./vendor

COPY . .

EXPOSE 9000
```

```bash
# Comparer les tailles d'images
docker build -t php-fpm-alpine:v1 .
docker images | grep php
# L'image alpine est beaucoup plus légère !
```

### Exercice 3.4 : Bonnes pratiques Dockerfile
```dockerfile
# MAUVAIS EXEMPLE - Plusieurs RUN créent plusieurs couches
FROM php:8.2-fpm
RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y zip
RUN apt-get clean

# BON EXEMPLE - Une seule couche, nettoyage inclus
FROM php:8.2-fpm
RUN apt-get update && apt-get install -y \
    git \
    zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

### Quiz TP3
1. À quoi sert l'instruction `FROM` ?
2. Quelle est la différence entre `COPY` et `ADD` ?
3. Pourquoi regrouper les commandes `RUN` ?
4. Qu'est-ce qu'un multi-stage build ?

---

## TP 4 : Docker Compose - Orchestrer plusieurs conteneurs

### Objectifs
- Comprendre Docker Compose
- Définir une stack multi-conteneurs
- Gérer les dépendances entre services

### Exercice 4.1 : Analyse du docker-compose.yml du projet

Étudiez le fichier `docker-compose.yml` à la racine du projet :
```yaml
services:
  nginx-iibs2:
    build: ./nginx
    ports:
      - "80:80"
    volumes:
      - ./:/var/www/html
    depends_on:
      - php-iibs2
    networks:
      - iibs-network

  php-iibs2:
    build: ./php
    expose:
      - "9000"
    volumes:
      - ./:/var/www/html
    networks:
      - iibs-network

  mysql-iibs2:
    image: mysql:8
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: php_iibs_db
      MYSQL_USER: phpuser
      MYSQL_PASSWORD: secret
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - iibs-network

networks:
  iibs-network:

volumes:
  mysql_data:
```

### Exercice 4.2 : Commandes Docker Compose
```bash
# Se placer dans le dossier du projet
cd C:\Users\m.lo\Downloads\php_iibs

# Construire les images
docker compose build

# Démarrer tous les services en arrière-plan
docker compose up -d

# Voir les logs de tous les services
docker compose logs

# Voir les logs d'un service spécifique
docker compose logs php-iibs2

# Suivre les logs en temps réel
docker compose logs -f

# Voir l'état des services
docker compose ps

# Exécuter une commande dans un service
docker compose exec php-iibs2 php -v

# Arrêter tous les services
docker compose stop

# Arrêter et supprimer les conteneurs
docker compose down

# Supprimer aussi les volumes
docker compose down -v
```

### Exercice 4.3 : Créer votre propre stack
```bash
mkdir ma-stack
cd ma-stack
```

Créez `docker-compose.yml` :
```yaml
version: '3.8'

services:
  # Application Node.js
  app:
    image: node:18-alpine
    working_dir: /app
    volumes:
      - ./app:/app
    ports:
      - "3000:3000"
    command: sh -c "npm install && npm start"
    depends_on:
      - redis
      - db
    environment:
      - NODE_ENV=development
      - REDIS_HOST=redis
      - DB_HOST=db

  # Cache Redis
  redis:
    image: redis:alpine
    ports:
      - "6379:6379"

  # Base de données PostgreSQL
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: myapp
    volumes:
      - pg_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  # Interface d'administration
  adminer:
    image: adminer
    ports:
      - "8080:8080"
    depends_on:
      - db

volumes:
  pg_data:
```

### Exercice 4.4 : Scaling avec Docker Compose
```bash
# Lancer plusieurs instances d'un service
docker compose up -d --scale php-iibs2=3

# Vérifier
docker compose ps

# Note : Le scaling avancé avec load balancing se fait plutôt avec Kubernetes
```

### Exercice 4.5 : Fichiers d'environnement
Créez `.env` :
```env
MYSQL_ROOT_PASSWORD=supersecret
MYSQL_DATABASE=production_db
APP_PORT=8080
```

Modifiez `docker-compose.yml` pour utiliser ces variables :
```yaml
services:
  db:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
    ports:
      - "${APP_PORT}:80"
```

### Quiz TP4
1. Quelle est la différence entre `ports` et `expose` ?
2. À quoi sert `depends_on` ?
3. Comment persister les données d'un service ?
4. Comment voir les logs d'un service spécifique ?

---

## TP 5 : Docker Registry et Publication d'images

### Objectifs
- Comprendre les registres Docker
- Publier une image sur Docker Hub
- Tagger correctement ses images

### Exercice 5.1 : Créer un compte Docker Hub
1. Allez sur https://hub.docker.com
2. Créez un compte gratuit
3. Notez votre nom d'utilisateur

### Exercice 5.2 : Se connecter à Docker Hub
```bash
# Se connecter
docker login

# Entrez votre nom d'utilisateur et mot de passe
# Ou utilisez un token d'accès (recommandé)
```

### Exercice 5.3 : Tagger et publier une image
```bash
# Format du tag : username/image:tag

# Construire l'image avec le bon tag
docker build -t votre-username/mon-app-php:v1 .

# Ou retagger une image existante
docker tag mon-app-php:v1 votre-username/mon-app-php:v1

# Publier sur Docker Hub
docker push votre-username/mon-app-php:v1

# Publier aussi avec le tag "latest"
docker tag votre-username/mon-app-php:v1 votre-username/mon-app-php:latest
docker push votre-username/mon-app-php:latest
```

### Exercice 5.4 : Stratégie de versioning
```bash
# Utiliser le versioning sémantique
docker build -t votre-username/mon-app-php:1.0.0 .
docker build -t votre-username/mon-app-php:1.0 .
docker build -t votre-username/mon-app-php:1 .
docker build -t votre-username/mon-app-php:latest .

# Utiliser le hash du commit Git
docker build -t votre-username/mon-app-php:$(git rev-parse --short HEAD) .

# Utiliser la date
docker build -t votre-username/mon-app-php:$(date +%Y%m%d) .
```

### Exercice 5.5 : Récupérer une image publiée
```bash
# Sur une autre machine ou après avoir supprimé l'image locale
docker pull votre-username/mon-app-php:v1

# Lancer le conteneur
docker run -d -p 8080:80 votre-username/mon-app-php:v1
```

### Quiz TP5
1. Qu'est-ce qu'un registry Docker ?
2. Pourquoi utiliser des tags de version ?
3. Quelle est la différence entre `docker build -t` et `docker tag` ?

---

## TP 6 : Introduction au CI/CD avec GitHub Actions

### Objectifs
- Comprendre les concepts CI/CD
- Créer un workflow GitHub Actions
- Automatiser le build et le push d'images Docker

### Concepts Clés

**CI (Continuous Integration)** :
- Intégration fréquente du code
- Tests automatiques à chaque commit
- Détection rapide des erreurs

**CD (Continuous Delivery/Deployment)** :
- Livraison automatique des artefacts
- Déploiement automatique (optionnel)

### Exercice 6.1 : Analyser le workflow existant

Étudiez `.github/workflows/demo.yml` :
```yaml
name: Build and Push Docker Image

on:
  push:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: check out code
        uses: actions/checkout@v4

      - name: login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build PHP Docker Image
        run: docker build -t ${{ secrets.DOCKER_USERNAME }}/mon-projet-php:latest ./php

      - name: Push Docker Image
        run: docker push ${{ secrets.DOCKER_USERNAME }}/mon-projet-php:latest
```

### Exercice 6.2 : Créer un workflow complet

Créez `.github/workflows/ci-cd.yml` :
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  REGISTRY: docker.io
  IMAGE_NAME: ${{ secrets.DOCKER_USERNAME }}/php-iibs

jobs:
  # Job 1 : Tests et validation
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout du code
        uses: actions/checkout@v4

      - name: Vérifier la syntaxe PHP
        run: |
          docker run --rm -v $PWD:/app php:8.2-cli php -l /app/index.php

      - name: Linter Dockerfile
        uses: hadolint/hadolint-action@v3.1.0
        with:
          dockerfile: php/Dockerfile

  # Job 2 : Build et Push
  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push'

    steps:
      - name: Checkout du code
        uses: actions/checkout@v4

      - name: Configuration de Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Extraire les métadonnées
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.IMAGE_NAME }}
          tags: |
            type=sha,prefix=
            type=ref,event=branch
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build et Push PHP
        uses: docker/build-push-action@v5
        with:
          context: ./php
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Build et Push Nginx
        uses: docker/build-push-action@v5
        with:
          context: ./nginx
          push: true
          tags: ${{ secrets.DOCKER_USERNAME }}/nginx-iibs:latest
          cache-from: type=gha
          cache-to: type=gha,mode=max

  # Job 3 : Notification (optionnel)
  notify:
    needs: build
    runs-on: ubuntu-latest
    if: always()
    steps:
      - name: Résultat du pipeline
        run: |
          echo "Build status: ${{ needs.build.result }}"
```

### Exercice 6.3 : Configurer les secrets GitHub

1. Allez dans votre repository GitHub
2. Settings → Secrets and variables → Actions
3. Créez ces secrets :
   - `DOCKER_USERNAME` : votre nom d'utilisateur Docker Hub
   - `DOCKER_PASSWORD` : votre token d'accès Docker Hub

### Exercice 6.4 : Déclencher le pipeline

```bash
# Faire une modification
echo "// Modification test CI/CD" >> index.php

# Commit et push
git add .
git commit -m "test: trigger CI/CD pipeline"
git push origin main

# Observer le pipeline dans l'onglet "Actions" de GitHub
```

### Exercice 6.5 : Ajouter des tests automatisés

Créez `.github/workflows/tests.yml` :
```yaml
name: Tests

on: [push, pull_request]

jobs:
  php-tests:
    runs-on: ubuntu-latest

    services:
      mysql:
        image: mysql:8
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: test_db
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          extensions: pdo_mysql, mysqli

      - name: Vérifier la connexion MySQL
        run: |
          mysql -h 127.0.0.1 -u root -proot -e "SHOW DATABASES;"

      - name: Exécuter les tests PHP
        run: |
          php -r "echo 'Tests PHP OK!';"
          # Ajoutez vos tests PHPUnit ici si vous en avez
          # ./vendor/bin/phpunit
```

### Quiz TP6
1. Quelle est la différence entre CI et CD ?
2. Qu'est-ce qu'un "job" dans GitHub Actions ?
3. Pourquoi utiliser des secrets pour les credentials ?
4. Que fait `needs: test` dans un job ?

---

## TP 7 : Pipeline CI/CD Avancé

### Objectifs
- Créer un pipeline multi-environnements
- Implémenter des déploiements conditionnels
- Gérer les versions automatiquement

### Exercice 7.1 : Pipeline avec environnements

Créez `.github/workflows/deploy.yml` :
```yaml
name: Deploy Pipeline

on:
  push:
    branches:
      - main
      - develop
    tags:
      - 'v*'

env:
  REGISTRY: docker.io

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Déterminer la version
        id: version
        run: |
          if [[ $GITHUB_REF == refs/tags/* ]]; then
            VERSION=${GITHUB_REF#refs/tags/}
          elif [[ $GITHUB_REF == refs/heads/main ]]; then
            VERSION=latest
          else
            VERSION=develop
          fi
          echo "version=$VERSION" >> $GITHUB_OUTPUT
          echo "Version: $VERSION"

      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build et Push
        uses: docker/build-push-action@v5
        with:
          context: ./php
          push: true
          tags: |
            ${{ secrets.DOCKER_USERNAME }}/php-iibs:${{ steps.version.outputs.version }}
            ${{ secrets.DOCKER_USERNAME }}/php-iibs:${{ github.sha }}

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/develop'
    environment: staging

    steps:
      - name: Déployer en staging
        run: |
          echo "Déploiement en staging avec la version: ${{ needs.build.outputs.version }}"
          # Ajoutez vos commandes de déploiement ici
          # kubectl apply -f k8s/ --context staging

  deploy-production:
    needs: build
    runs-on: ubuntu-latest
    if: startsWith(github.ref, 'refs/tags/v')
    environment: production

    steps:
      - name: Déployer en production
        run: |
          echo "Déploiement en production avec la version: ${{ needs.build.outputs.version }}"
          # kubectl apply -f k8s/ --context production
```

### Exercice 7.2 : Matrice de builds

```yaml
name: Matrix Build

on: push

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        php-version: ['8.1', '8.2', '8.3']
        include:
          - php-version: '8.2'
            is-default: true

    steps:
      - uses: actions/checkout@v4

      - name: Build PHP ${{ matrix.php-version }}
        run: |
          docker build \
            --build-arg PHP_VERSION=${{ matrix.php-version }} \
            -t php-app:${{ matrix.php-version }} \
            ./php

      - name: Push default version
        if: matrix.is-default
        run: |
          echo "Cette version serait poussée comme latest"
```

### Exercice 7.3 : Workflow réutilisable

Créez `.github/workflows/docker-build.yml` :
```yaml
name: Reusable Docker Build

on:
  workflow_call:
    inputs:
      image-name:
        required: true
        type: string
      context:
        required: true
        type: string
      dockerfile:
        required: false
        type: string
        default: 'Dockerfile'
    secrets:
      DOCKER_USERNAME:
        required: true
      DOCKER_PASSWORD:
        required: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - uses: docker/build-push-action@v5
        with:
          context: ${{ inputs.context }}
          file: ${{ inputs.context }}/${{ inputs.dockerfile }}
          push: true
          tags: ${{ secrets.DOCKER_USERNAME }}/${{ inputs.image-name }}:latest
```

Utilisez-le dans un autre workflow :
```yaml
name: Build All Images

on: push

jobs:
  build-php:
    uses: ./.github/workflows/docker-build.yml
    with:
      image-name: php-iibs
      context: ./php
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}

  build-nginx:
    uses: ./.github/workflows/docker-build.yml
    with:
      image-name: nginx-iibs
      context: ./nginx
    secrets:
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
```

### Exercice 7.4 : Release automatique avec tags

```bash
# Créer un tag de version
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# Le pipeline détectera le tag et :
# 1. Construira l'image avec le tag v1.0.0
# 2. Déclenchera le déploiement en production
```

### Quiz TP7
1. Comment conditionner l'exécution d'un job ?
2. Qu'est-ce qu'une matrice de build ?
3. Comment passer des données entre jobs ?
4. Qu'est-ce qu'un workflow réutilisable ?

---

## TP 8 : Projet Final - Pipeline Complet

### Objectif
Créer un pipeline CI/CD complet qui :
1. Valide le code (lint, tests)
2. Construit les images Docker
3. Publie sur Docker Hub
4. Déploie automatiquement

### Exercice 8.1 : Structure finale du projet

```
php_iibs/
├── .github/
│   └── workflows/
│       ├── ci.yml          # Tests et validation
│       ├── cd.yml          # Build et déploiement
│       └── pr-check.yml    # Vérification des PR
├── php/
│   └── Dockerfile
├── nginx/
│   ├── Dockerfile
│   └── default.conf
├── k8s/                    # Pour Kubernetes (bonus)
├── docker-compose.yml
├── docker-compose.prod.yml
└── index.php
```

### Exercice 8.2 : Pipeline CI complet

Créez `.github/workflows/ci.yml` :
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Lint PHP
        run: |
          find . -name "*.php" -exec php -l {} \;

      - name: Lint Dockerfiles
        uses: hadolint/hadolint-action@v3.1.0
        with:
          dockerfile: php/Dockerfile
          failure-threshold: warning

  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Scan des vulnérabilités
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: '.'
          severity: 'CRITICAL,HIGH'

  test:
    runs-on: ubuntu-latest
    needs: [lint]

    services:
      mysql:
        image: mysql:8
        env:
          MYSQL_ROOT_PASSWORD: root
          MYSQL_DATABASE: test
        ports:
          - 3306:3306
        options: --health-cmd="mysqladmin ping" --health-interval=10s --health-timeout=5s --health-retries=3

    steps:
      - uses: actions/checkout@v4

      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: '8.2'
          extensions: pdo_mysql

      - name: Tests unitaires
        run: |
          echo "Exécution des tests..."
          # ./vendor/bin/phpunit si vous avez PHPUnit

  build-test:
    runs-on: ubuntu-latest
    needs: [lint]
    steps:
      - uses: actions/checkout@v4

      - name: Build des images (sans push)
        run: |
          docker compose build

      - name: Test de démarrage
        run: |
          docker compose up -d
          sleep 10
          curl -f http://localhost:80 || exit 1
          docker compose down
```

### Exercice 8.3 : Pipeline CD complet

Créez `.github/workflows/cd.yml` :
```yaml
name: CD

on:
  push:
    branches: [main]
    tags: ['v*']
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environnement de déploiement'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.version }}

    steps:
      - uses: actions/checkout@v4

      - name: Set up QEMU
        uses: docker/setup-qemu-action@v3

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ secrets.DOCKER_USERNAME }}/php-iibs
          tags: |
            type=ref,event=branch
            type=ref,event=tag
            type=sha,prefix=
            type=raw,value=latest,enable={{is_default_branch}}

      - name: Build and push PHP
        uses: docker/build-push-action@v5
        with:
          context: ./php
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

      - name: Build and push Nginx
        uses: docker/build-push-action@v5
        with:
          context: ./nginx
          platforms: linux/amd64,linux/arm64
          push: true
          tags: ${{ secrets.DOCKER_USERNAME }}/nginx-iibs:${{ steps.meta.outputs.version }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy:
    needs: build-and-push
    runs-on: ubuntu-latest
    environment: ${{ github.event.inputs.environment || 'staging' }}

    steps:
      - uses: actions/checkout@v4

      - name: Afficher les informations de déploiement
        run: |
          echo "🚀 Déploiement de l'image: ${{ needs.build-and-push.outputs.image-tag }}"
          echo "📍 Environnement: ${{ github.event.inputs.environment || 'staging' }}"

      # Exemple de déploiement Kubernetes
      # - name: Deploy to Kubernetes
      #   run: |
      #     kubectl set image deployment/php-app php=${{ secrets.DOCKER_USERNAME }}/php-iibs:${{ needs.build-and-push.outputs.image-tag }}

  notify:
    needs: [build-and-push, deploy]
    runs-on: ubuntu-latest
    if: always()
    steps:
      - name: Notification de résultat
        run: |
          if [ "${{ needs.deploy.result }}" == "success" ]; then
            echo "✅ Déploiement réussi!"
          else
            echo "❌ Échec du déploiement"
          fi
```

### Exercice 8.4 : Checklist finale

- [ ] Le code est versionné avec Git
- [ ] Un Dockerfile optimisé existe pour chaque service
- [ ] docker-compose.yml permet le développement local
- [ ] Les secrets sont configurés dans GitHub
- [ ] Le pipeline CI vérifie chaque commit
- [ ] Le pipeline CD déploie automatiquement
- [ ] Les images sont taguées correctement
- [ ] La documentation est à jour

---

## Récapitulatif des Compétences Acquises

| TP | Compétences |
|-----|-------------|
| TP1 | Commandes Docker de base, conteneurs, images |
| TP2 | Ports, volumes, variables d'environnement |
| TP3 | Création d'images, Dockerfile, optimisation |
| TP4 | Docker Compose, orchestration multi-conteneurs |
| TP5 | Registry, publication d'images, versioning |
| TP6 | GitHub Actions, CI/CD basique |
| TP7 | Pipelines avancés, multi-environnements |
| TP8 | Projet complet, intégration de tous les concepts |

---

## Ressources Complémentaires

- [Documentation Docker](https://docs.docker.com/)
- [Documentation Docker Compose](https://docs.docker.com/compose/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Hub](https://hub.docker.com/)
- [Play with Docker](https://labs.play-with-docker.com/) - Environnement d'apprentissage en ligne

---

## Prochaines Étapes

Après avoir maîtrisé ces TP, vous pouvez explorer :
1. **Kubernetes** - Voir le dossier `k8s/` de ce projet
2. **Helm** - Gestionnaire de packages Kubernetes
3. **ArgoCD** - GitOps pour Kubernetes
4. **Monitoring** - Prometheus, Grafana
5. **Service Mesh** - Istio, Linkerd
