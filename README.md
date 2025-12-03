# **CueCards Deploy**

This repository contents only Kubernetes manifests for [CueCards project](https://github.com/GRD-1/CueCards).
It can be updated in two cases:

- by a user with an "admin" role when you need to update a cluster configuration
- by [github workflow](https://github.com/GRD-1/CueCards/blob/main/.github/workflows/release.orchestrator.yml)
  from [CueCards project](https://github.com/GRD-1/CueCards)

**Release workflow**

- this workflow is stored in a [CueCards project](https://github.com/GRD-1/CueCards)
- it should be triggered by each push to the "main" branch

## **Table of contents**

1. [Overview](#overview)
2. [What we already have](#what-we-alredy-have)
3. [File Structure](#file-structure)
4. [Setup](#setup)
5. [Launch](#launch)

## **Overview**

This document describes CueCards project deployment in production mode on [Kubernetes](https://kubernetes.io/) (k3s). Details:

Clusters:

- now we have limited resources: 2CPU + 4gb ram + 80gb disk space,
- so for now we create only a single cluster `cluster-a`

## **What we alredy have**

1. we have a domain "cuecards.online" and a subdomain "api.cuecards.online"
2. a droplet created on digitalocean.com: 2CPU + 4gb ram + 80gb disk space
3. a cluster launched via k3s on this droplet
4. a metallb loadBalancer installed
5. an ingress-nginx-controller installed
6. two stateless resouces are prepared for apps: "api" and "web"
7. two ingress-resources prepared, one for each application
8. Pods routing now managed by ingress-controller
9. Three separate repositories are stored the project files:

- https://github.com/GRD-1/CueCards - contents the project code
- https://github.com/GRD-1/CueCards-deploy - contents the kubernetes manifests
- ghcr.io/grd-1 - store the application images

10. Repositories are managed by github workflow in https://github.com/GRD-1/CueCards. It:

- starts when a new commit is pushed to a 'main' branch
- publishes app images to ghcr.io/grd-1
- updates image tags in kubernetes manifests in https://github.com/GRD-1/CueCards-deploy

11. Argo CD is installed
12. An SSH key pair generated locally. The public key added to the repository as a "deploy key"
13. ArgoCd configuration templated in `kubernetes/infra/argocd/app-of-apps.yaml`
14. ArgoCd ssh connection is configured via UI and synchronizes with github repo automatically
15. Cert-manager installed and connected to ingress resources.
16. Two applicationas now are available from the internet via https: web and api
17. Postgres operator installed via Bitnami helm, postgress is available via pod port 5432
18. Created the secrets. secrets added to the app deployments
19. Helper scripts are in `kubernetes/scripts/`

## **File structure**

```plaintext
kubernetes/
│
├─ clusters/                     # cluster-specific cofigs
│  └─ cluster-a/
│     ├─ argocd-apps/            # Argo CD Application manifests for this cluster
│     └─ apps/                   # cluster-specific overlays (kustomize/helm values)
│        ├─ api/
│        ├─ web/
│        ├─ postgres-cr/
│        └─ redis-cr/
│
├─ infra/                        # base infrastructure levels above the clusters
│  ├─ argocd/                    # Argo CD installation and configuration
|  ├─ cert-manager               # Cert-manager that automatically issues and renews TLS certificates
|  ├─ cluster-setup              # base cluster setup
│  ├─ logging/                   # Loki, Fluentd, ELK, etc.
│  ├─ monitoring/                # Prometheus, Grafana, alerting, metrics
│  ├─ networking/                # Ingress controllers, DNS, load balancer setup
│  ├─ operators/                 # Kubernetes Operators (Postgres, Redis, etc.)
│  └─ security/                  # RBAC rules, network policies, admission controllers
│
├─ secrets/                      # ENCRYPTED secrets (SOPS)
│  ├─ cluster-a/
│  └─ cluster-b/
│
└─ scripts/                      # helper scripts (image bump, deploy, local testing)
```

## **Setup**

## **Launch**
