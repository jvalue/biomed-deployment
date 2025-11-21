# Argo Workflows Helm Chart

This Helm chart deploys Argo Workflows using the official upstream chart as a dependency.

## Overview

This is a wrapper chart that uses the official [Argo Workflows Helm chart](https://github.com/argoproj/argo-helm) as a dependency, allowing for easier maintenance and upgrades while maintaining custom configurations.

## Prerequisites

- Kubernetes cluster with access configured
- Helm 3.x installed
- kubectl configured to access the target cluster

## Installation

### 1. Update Dependencies

Before installing, ensure the chart dependencies are downloaded:

```bash
helm dependency update
```

This will download the upstream Argo Workflows chart (v0.45.28) to the `charts/` directory.

### 2. Install the Chart

Install the chart in the `argo` namespace:

```bash
helm install argo-workflows . --namespace argo --create-namespace
```

Or upgrade an existing installation:

```bash
helm upgrade argo-workflows . --namespace argo
```

### 3. Verify Installation

Check that all resources are deployed:

```bash
kubectl get all -n argo -l 'app.kubernetes.io/part-of=argo-workflows'
```

Verify the ingress is created:

```bash
kubectl get ingress -n argo
```

## Configuration

The chart is configured via the `values.yaml` file. All values under the `argo-workflows` key are passed to the upstream chart.

## Uninstallation

To remove the deployment:

```bash
helm uninstall argo-workflows --namespace argo
```

Note: CRDs are kept by default (configured with `keep: true`). To remove them manually:

```bash
kubectl delete crd workflows.argoproj.io
kubectl delete crd cronworkflows.argoproj.io
kubectl delete crd clusterworkflowtemplates.argoproj.io
kubectl delete crd workflowtemplates.argoproj.io
kubectl delete crd workfloweventbindings.argoproj.io
kubectl delete crd workflowtasksets.argoproj.io
kubectl delete crd workflowtaskresults.argoproj.io
kubectl delete crd workflowartifactgctasks.argoproj.io
```

## Additional Resources

- [Argo Workflows Documentation](https://argo-workflows.readthedocs.io/)
- [Argo Helm Charts Repository](https://github.com/argoproj/argo-helm)
- [Argo Workflows GitHub](https://github.com/argoproj/argo-workflows)
