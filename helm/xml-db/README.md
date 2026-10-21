# XML / Crawler PostgreSQL Helm Chart

Helm chart for deploying PostgreSQL for the XML ingestor, crawler, and downloader pipeline in namespace `argo-managed-crawler`.

## Quick Start

### Installation

```bash
helm upgrade --install crawler-db ./helm/xml-db -n argo-managed-crawler
```

### Verification

```bash
kubectl get pods,svc,secrets -n argo-managed-crawler -l app.kubernetes.io/name=xml-db
```

## Configuration

| Parameter | Default | Description |
|---|---|---|
| `database.name` | `xml` | Default PostgreSQL database name |
| `database.user` | `postgres` | Default PostgreSQL user |
| `database.password` | `CHANGE_ME_DATABASE_PASSWORD` | PostgreSQL password |
| `secret.name` | `crawler-db-credentials` | Kubernetes secret name referenced by workflow templates |
| `service.name` | `crawler-db` | Kubernetes Service name (`crawler-db.argo-managed-crawler.svc.cluster.local`) |
| `service.port` | `5436` | Primary Service port (matches workflow template defaults) |
| `persistence.enabled` | `true` | Enable PersistentVolumeClaim storage |
| `persistence.size` | `10Gi` | Storage request size |
