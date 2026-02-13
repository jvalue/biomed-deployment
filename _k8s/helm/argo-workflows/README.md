# Argo Workflows Helm Chart

This Helm chart deploys Argo Workflows using the official upstream chart as a dependency, including MinIO for artifact storage.

## Overview

This is a wrapper chart that uses the official [Argo Workflows Helm chart](https://github.com/argoproj/argo-helm) and [MinIO Helm chart](https://github.com/minio/minio/tree/master/helm/minio) as dependencies, allowing for easier maintenance and upgrades while maintaining custom configurations.

## Components

- **Argo Workflows**: Workflow engine for Kubernetes
- **MinIO**: S3-compatible object storage for workflow artifacts and logs

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

The chart is configured via the `values.yaml` file. All values under the `argo-workflows` key are passed to the upstream Argo Workflows chart, and all values under `minio` are passed to the upstream MinIO chart.

## Accessing MinIO

Get the MinIO root credentials:

```bash
export ROOT_USER=$(kubectl get secret --namespace argo argo-workflows-minio -o jsonpath="{.data.rootUser}" | base64 -d)
export ROOT_PASSWORD=$(kubectl get secret --namespace argo argo-workflows-minio -o jsonpath="{.data.rootPassword}" | base64 -d)
```

Port-forward to access the MinIO console:

```bash
kubectl port-forward --namespace argo svc/argo-workflows-minio-console 9001:9001
```

Then open http://localhost:9001 in your browser.

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
