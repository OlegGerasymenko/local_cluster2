# PHP App GitOps Manifests

This repository contains Kustomize bases and Argo CD definitions for a simple PHP
application. The structure enables consistent promotion between environments and
keeps production hardening focused in overlays instead of the base charts.

## Layout

- `php-app/base`: Namespace-agnostic Deployment, Service, and ConfigMap
  definitions shared by every environment.
- `php-app/overlays/dev1`: Development overlay that enables verbose PHP errors
  and runs two replicas inside the `php-app-dev1` namespace.
- `php-app/overlays/dev2`: Secondary development overlay that mimics a
  production posture (errors disabled) while still running two replicas.
- `argocd/projects`: AppProject manifests whitelisting the repository and
  target namespaces.
- `argocd/applications`: Per-environment Application manifests that point Argo
  CD at the appropriate overlay.

## Usage

1. Update `repoURL` values so they match the Git remote housing these files.
2. Apply `argocd/projects/php-app.yaml` into the Argo CD control plane
   namespace.
3. Apply each Application manifest, or let an existing management pipeline do
   so. Argo CD will automatically create namespaces and deploy the PHP app.

To add `uat` or `prod` environments later, copy one of the existing overlays,
adjust namespace-specific policies, and register new Applications under the
same AppProject.
