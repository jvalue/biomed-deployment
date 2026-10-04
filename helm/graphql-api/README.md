# GraphQL API Helm Chart

Deploys the Strawberry GraphQL API service in Kubernetes.

## Prerequisites

- PostgreSQL database running (e.g. `biomed-management-release-database` in `management` namespace).
- MinIO / S3 object storage running (e.g. `argo-workflows-minio` in `argo` namespace).
- Docker image built and available (or loaded into Minikube).

## Build Docker Image for Minikube

From the `biomed` repository root:
```bash
docker build -t biomed-graphql-api:local -f apps/graphql_api/Dockerfile .
minikube image load biomed-graphql-api:local
```

## Deploying to Minikube

From the `biomed-deployment` repository root:
```bash
helm upgrade --install graphql-api helm/graphql-api -n management
```

## Verifying Deployment

```bash
# Check pod status
kubectl get pods -n management -l app.kubernetes.io/name=graphql-api

# Port forward to host
kubectl -n management port-forward svc/graphql-api 8003:8003
```

- Health check: `http://localhost:8003/health`
- GraphiQL explorer: `http://localhost:8003/graphql`

## Uninstall

```bash
helm uninstall graphql-api -n management
```
