# Argo Workflows Helm Chart

This Helm chart deploys Argo Workflows using the official upstream chart as a dependency, including MinIO for artifact storage and log archiving.

## Overview

This is a wrapper chart that uses the official [Argo Workflows Helm chart](https://github.com/argoproj/argo-helm) and [MinIO Helm chart](https://github.com/minio/minio/tree/master/helm/minio) as dependencies, allowing for easier maintenance and upgrades while maintaining custom configurations.

## Components

- **Argo Workflows v3.7.3**: Workflow engine for Kubernetes
- **MinIO**: S3-compatible object storage for workflow artifacts and logs
- **PostgreSQL**: Workflow metadata persistence and archiving
- **Traefik Ingress**: Exposes Argo UI under `/argo/` path

## Features

- ✅ **Log Archiving**: Container logs are automatically saved to MinIO (`archiveLogs: true`)
- ✅ **Pod Garbage Collection**: Pods are deleted after 5 minutes to free resources

## Prerequisites

- Kubernetes cluster with access configured
- Helm 3.x installed
- kubectl configured to access the target cluster
- Storage class `longhorn-basic-backup` available (or adjust in `values.yaml`)

## Installation

### 1. Create MinIO Secrets

**IMPORTANT:** Create the MinIO credentials secrets in both namespaces BEFORE installing the chart.

```bash
# Generate a secure password
export MINIO_PASSWORD=$(openssl rand -base64 32)

# Create secret in argo namespace (for MinIO pod)
kubectl create secret generic argo-workflows-minio \
  --from-literal=rootUser=minioadmin \
  --from-literal=rootPassword="$MINIO_PASSWORD" \
  -n argo --create-namespace

# Create the same secret in workflow namespace (for workflow pods)
kubectl create secret generic argo-workflows-minio \
  --from-literal=rootUser=minioadmin \
  --from-literal=rootPassword="$MINIO_PASSWORD" \
  -n argo-managed-crawler --create-namespace
```

**Why two secrets?**
- `argo-workflows-minio` in `argo` namespace: Used by the MinIO pod itself
- `argo-workflows-minio` in `argo-managed-crawler` namespace: Used by workflow pods to access MinIO

Both secrets must have identical credentials!

### 2. Update Dependencies

Download the chart dependencies:

```bash
helm dependency update
```

This will download:
- Argo Workflows chart (v0.45.28)
- MinIO chart (v5.4.0)

### 3. Install the Chart

```bash
helm install argo-workflows . --namespace argo --create-namespace
```

Or upgrade an existing installation:

```bash
helm upgrade argo-workflows . --namespace argo
```

### 3. Install the Chart

Install the chart in the `argo` namespace:

```bash
helm install argo-workflows . --namespace argo --create-namespace
```

Or upgrade an existing installation:

```bash
helm upgrade argo-workflows . --namespace argo
```

### 4. Verify Installation

Check that all resources are deployed:

```bash
# Check pods
kubectl get pods -n argo

# Check services
kubectl get svc -n argo

# Check ingress
kubectl get ingress -n argo
```

Expected pods:
- `argo-workflows-server-*`: Argo UI and API server
- `argo-workflows-workflow-controller-*`: Workflow execution controller
- `argo-workflows-minio-*`: MinIO object storage
- `argo-workflows-database-*`: PostgreSQL database

## Configuration

The chart is configured via the `values.yaml` file. All values under the `argo-workflows` key are passed to the upstream Argo Workflows chart, and all values under `minio` are passed to the upstream MinIO chart.

### Workflow Defaults

All workflows inherit these defaults:

#### Pod Garbage Collection
```yaml
podGC:
  strategy: OnPodCompletion       # Delete pods after completion
  deleteDelayDuration: 5m         # Wait 5 minutes (for log archiving)
```

**Effect:** Pods are deleted 5 minutes after completion, freeing cluster resources while keeping workflow metadata.

**Timeline:**
1. Workflow completes → Logs uploaded to MinIO
2. After 5 minutes → Pod deleted
3. Workflow metadata remains in database
4. Logs remain accessible via MinIO

### Multi-Namespace Support

Workflows can run in the `argo-managed-crawler` namespace (configured in `values.yaml`):

```yaml
controller:
  workflowNamespaces:
    - argo-managed-crawler
```

Workflows in this namespace can access the MinIO secret because it's replicated there.

## Accessing Argo Workflows

### Via Ingress

Access the Argo UI at: `http://your-domain/argo/`

The ingress is configured with:
- Path: `/argo`
- IngressClass: `private-ingress`
- Middleware: `argo-workflows-strip-prefix` (removes `/argo` prefix)

### Authentication

Get a service account token:

```bash
kubectl create token argo-user -n argo --duration=24h
```

Use this token in the Argo UI login.

## Accessing MinIO

### Via Console

Port-forward to access the MinIO console:
### Via Console

Port-forward to access the MinIO console:

```bash
kubectl port-forward --namespace argo svc/argo-workflows-minio-console 9001:9001
```

Then open http://localhost:9001 in your browser.

### Get Credentials

Retrieve the MinIO credentials from either namespace:

```bash
# From argo namespace
kubectl get secret argo-workflows-minio -n argo -o jsonpath='{.data.rootUser}' | base64 -d
kubectl get secret argo-workflows-minio -n argo -o jsonpath='{.data.rootPassword}' | base64 -d

# From workflow namespace (same credentials)
kubectl get secret argo-workflows-minio -n argo-managed-crawler -o jsonpath='{.data.rootUser}' | base64 -d
kubectl get secret argo-workflows-minio -n argo-managed-crawler -o jsonpath='{.data.rootPassword}' | base64 -d
```

## Log Archiving

### How It Works

1. **Workflow runs** → Container outputs logs
2. **Workflow completes** → Logs are uploaded to MinIO (`s3://argo-artifacts/...`)
3. **After 5 minutes** → Pod is deleted (podGC)
4. **Logs remain** → Accessible via API/UI from MinIO indefinitely


## Troubleshooting

### Pods stuck with "Secret not found" errors

Ensure the MinIO secret exists in both namespaces:

```bash
kubectl get secret argo-workflows-minio -n argo
kubectl get secret argo-workflows-minio -n argo-managed-crawler
```

If missing, create them following the installation instructions.

### Logs not archiving

Check controller logs:

```bash
kubectl logs -n argo -l app.kubernetes.io/name=argo-workflows-workflow-controller --tail=100
```

Verify MinIO is accessible:

```bash
kubectl exec -n argo deploy/argo-workflows-minio -- ls /export/argo-artifacts/
```

### MinIO credentials mismatch

Both secrets must have identical credentials. Verify:

```bash
# Check argo namespace
kubectl get secret argo-workflows-minio -n argo -o jsonpath='{.data.rootPassword}' | base64 -d

# Check workflow namespace
kubectl get secret argo-workflows-minio -n argo-managed-crawler -o jsonpath='{.data.rootPassword}' | base64 -d
```

If they differ, update both secrets to match.

### MinIO pod failing to start

Check MinIO logs:

```bash
kubectl logs -n argo -l app.kubernetes.io/name=minio
```

Common issues:
- Wrong secret format (needs `rootUser` and `rootPassword` keys)
- Storage class not available
- Insufficient resources

## Uninstallation

To remove the deployment:

```bash
helm uninstall argo-workflows --namespace argo
```

**Note:** This will NOT delete:
- CRDs (kept for safety)
- PersistentVolumeClaims (MinIO data)
- The manual secrets `argo-workflows-minio` in both namespaces

To fully clean up:

```bash
# Delete PVCs (WARNING: This deletes all MinIO data!)
kubectl delete pvc -l app.kubernetes.io/instance=argo-workflows -n argo

# Delete secrets in both namespaces
kubectl delete secret argo-workflows-minio -n argo
kubectl delete secret argo-workflows-minio -n argo-managed-crawler

# Delete CRDs (WARNING: This deletes all workflows cluster-wide!)
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
- [MinIO Documentation](https://min.io/docs/minio/kubernetes/upstream/)
- [Log Archiving Configuration](https://argo-workflows.readthedocs.io/en/latest/configure-artifact-repository/)
