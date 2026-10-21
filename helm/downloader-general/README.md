# Downloader General Helm Chart

Helm chart for deploying the long-running generic downloader worker service in namespace `argo-managed-crawler`.

The downloader continuously consumes download tasks from the shared RabbitMQ `download-urls` queue, downloads files over HTTP/FTP, uploads them to S3/MinIO with proper source prefixes (`downloader-files/<db_name>/...`), and updates tracking status in PostgreSQL (`crawler-db`).

## Quick Start

### Installation

```bash
helm upgrade --install downloader-general ./helm/downloader-general -n argo-managed-crawler
```

### Verification

```bash
kubectl get pods,deployment -n argo-managed-crawler -l app.kubernetes.io/name=downloader-general
kubectl logs -n argo-managed-crawler -l app.kubernetes.io/name=downloader-general -f
```

## Configuration

| Parameter | Default | Description |
|---|---|---|
| `replicaCount` | `1` | Number of worker pod replicas |
| `image.repository` | `ghcr.io/jvalue/downloader-general` | Container image repository |
| `image.tag` | `25f73adeeba79009c53c8b72abdedeaea3720806` | Image tag |
| `rabbitmq.url` | `amqp://guest:CHANGE_ME@rabbitmq.argo-managed-crawler.svc.cluster.local:5672/` | RabbitMQ connection URL |
| `rabbitmq.queue` | `download-urls` | Task queue name |
| `s3.endpointUrl` | `http://minio.biomed.svc.cluster.local:9000` | S3 / MinIO endpoint URL |
| `s3.bucket` | `biomed-data` | S3 target bucket |
| `s3.uploadPrefix` | `downloader-files` | Target prefix in bucket |
| `database.host` | `crawler-db.argo-managed-crawler.svc.cluster.local` | PostgreSQL host |
| `database.port` | `5436` | PostgreSQL port |
