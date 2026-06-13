# ─────────────────────────────────────────────────────────────────────────────
# Cur8s Flux — foundation repo
#
# Builds an opinionated Flux configuration, publishes it as an OCI artifact, and
# can stand up a disposable k3d cluster to test the whole bootstrap → reconcile
# loop end to end.
#
# Pipeline:  fetch → render → validate → (cluster → init → push → sync → verify)
# ─────────────────────────────────────────────────────────────────────────────

REPO_ROOT := $(shell git rev-parse --show-toplevel)

# Flux release this repo tracks. A new upstream Flux release == a new VERSION
# here == a new published OCI artifact (see docs/rfc, RFC-009).
FLUX_VERSION := $(shell cat $(REPO_ROOT)/VERSION)

# Kubernetes API version used for manifest validation.
KUBE_VERSION ?= 1.33.0

# Production registry (override for forks). Dev uses the k3d-local registry.
REGISTRY     ?= ghcr.io/cur8s
CLUSTER_NAME ?= flux-dev

export REPO_ROOT FLUX_VERSION KUBE_VERSION REGISTRY CLUSTER_NAME
export PATH := $(REPO_ROOT)/scripts/lib:$(REPO_ROOT)/scripts/make:$(PATH)

SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c

.PHONY: all help clean fetch render validate build cluster init push sync verify watch e2e check-update release

all: help

# ── DEV (filesystem only) ────────────────────────────────────────────────────

clean: ## Remove generated artifacts
	@rm -rf $(REPO_ROOT)/src/flux/artifacts $(REPO_ROOT)/oci
	@mkdir -p $(REPO_ROOT)/src/flux/artifacts/fetched/manifests
	@echo "✅ cleaned"

fetch: ## Generate the opinionated Flux install manifest (offline, via flux CLI)
	@echo "🔽 Generating Flux $(FLUX_VERSION) install manifest (source/kustomize/notification)..."
	@mkdir -p $(REPO_ROOT)/src/flux/artifacts/fetched/manifests
	@flux install \
		--components=source-controller,kustomize-controller,notification-controller \
		--namespace=flux-system \
		--version=$(FLUX_VERSION) \
		--export > $(REPO_ROOT)/src/flux/artifacts/fetched/manifests/flux.yaml
	@digest=$$(openssl dgst -sha256 $(REPO_ROOT)/src/flux/artifacts/fetched/manifests/flux.yaml | awk '{print $$NF}'); \
	  { \
	    echo "# Audit trail for fetched upstream sources. Regenerate with 'make fetch'."; \
	    echo "component: flux"; \
	    echo "flux-version: $(FLUX_VERSION)"; \
	    echo "cli-version: $$(flux --version | awk '{print $$NF}')"; \
	    echo "sources:"; \
	    echo "  - type: flux-cli-install"; \
	    echo "    file: manifests/flux.yaml"; \
	    echo "    digest: sha256:$$digest"; \
	  } > $(REPO_ROOT)/src/flux/artifacts/FETCH.lock
	@echo "   ✅ src/flux/artifacts/fetched/manifests/flux.yaml"

render: ## Render the opinionated overlay into the OCI artifact tree (oci/flux/)
	@echo "🔨 Rendering opinionated config → oci/flux/ ..."
	@mkdir -p $(REPO_ROOT)/oci/flux/deploy
	@kustomize build --load-restrictor=LoadRestrictionsNone \
		$(REPO_ROOT)/src/flux/config/overlays/deploy > $(REPO_ROOT)/oci/flux/deploy/flux.yaml
	@cp $(REPO_ROOT)/src/flux/config/sync.yaml $(REPO_ROOT)/oci/flux/sync.yaml
	@echo "   ✅ oci/flux/deploy/flux.yaml"
	@echo "   ✅ oci/flux/sync.yaml"

validate: ## Validate rendered manifests with kubeconform
	@$(REPO_ROOT)/scripts/make/validate

build: clean fetch render validate ## clean → fetch → render → validate
	@echo ""
	@echo "✅ build complete — artifact tree in oci/flux/"

# ── TEST (needs docker + k3d) ────────────────────────────────────────────────

cluster: ## Create a disposable k3d cluster + local registry
	@$(REPO_ROOT)/scripts/cluster create $(CLUSTER_NAME)

init: ## Bootstrap Flux into the cluster (kubectl apply of rendered manifest)
	@$(REPO_ROOT)/scripts/make/init $(CLUSTER_NAME)

push: build ## Build, then push the OCI artifact to the cluster's local registry
	@$(REPO_ROOT)/scripts/make/push k3d $(CLUSTER_NAME) dev

sync: ## Hand Flux the OCIRepository + Kustomization so it self-manages
	@$(REPO_ROOT)/scripts/make/sync $(CLUSTER_NAME) dev

verify: ## Verify controllers + self-management Kustomization are Ready
	@$(REPO_ROOT)/scripts/make/verify $(CLUSTER_NAME)

watch: ## Watch Flux reconciliation
	@watch flux --context k3d-$(CLUSTER_NAME) get all -A

e2e: ## Full ephemeral test: build → cluster → push → init → sync → verify
	@$(REPO_ROOT)/scripts/make/e2e

# ── MAINTENANCE / PUBLISH ────────────────────────────────────────────────────

check-update: ## Report whether a newer upstream Flux release exists
	@$(REPO_ROOT)/scripts/make/check-update

release: build ## Push the OCI artifact to the production registry, tagged by Flux version
	@$(REPO_ROOT)/scripts/make/push oci $(REGISTRY) $(FLUX_VERSION)

help:
	@echo "Cur8s Flux — foundation repo"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  FLUX_VERSION = $(FLUX_VERSION)   CLUSTER_NAME = $(CLUSTER_NAME)   REGISTRY = $(REGISTRY)"
