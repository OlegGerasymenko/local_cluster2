SHELL := /bin/bash
.ONESHELL:

ROOT_DIR := /Users/oleg.gerasimenko/learn/local_cluster2
PROJECT_FILE := $(ROOT_DIR)/argocd/projects/php-app.yaml
APP_DEV1_FILE := $(ROOT_DIR)/argocd/applications/php-app-dev1.yaml
APP_DEV2_FILE := $(ROOT_DIR)/argocd/applications/php-app-dev2.yaml
KUBECTL ?= kubectl
MINIKUBE ?= minikube
ARGO_VERSION ?= stable

.PHONY: bootstrap minikube-start argo-install project deploy-dev1 deploy-dev2 deploy-apps \
  argocd-password argocd-port-forward

bootstrap: argo-install deploy-apps

minikube-start:
	set -euo pipefail
	$(MINIKUBE) start  --addons=ingress

argo-install: minikube-start
	set -euo pipefail
	$(KUBECTL) create namespace argocd --dry-run=client -o yaml \
	  | $(KUBECTL) apply -f -
	curl -sSL \
	  https://raw.githubusercontent.com/argoproj/argo-cd/$(ARGO_VERSION)/manifests/install.yaml \
	  | $(KUBECTL) apply -n argocd -f -

project:
	set -euo pipefail
	$(KUBECTL) apply -f $(PROJECT_FILE)

deploy-dev1: project
	set -euo pipefail
	$(KUBECTL) apply -f $(APP_DEV1_FILE)

deploy-dev2: project
	set -euo pipefail
	$(KUBECTL) apply -f $(APP_DEV2_FILE)

deploy-apps: deploy-dev1 deploy-dev2

argocd-password:
	set -euo pipefail
	$(KUBECTL) get secret argocd-initial-admin-secret -n argocd \
	  -o jsonpath='{.data.password}' | base64 --decode && echo

argocd-port-forward:
	set -euo pipefail
	$(KUBECTL) port-forward svc/argocd-server -n argocd 8080:443
