# RabbitMQ Helm Chart

This Helm chart deploys RabbitMQ using the Bitnami RabbitMQ chart as a dependency.

Configuration is in `values.yaml`.

Installation

1. Update dependencies:
```bash
cd helm/rabbitmq
helm dependency update
```

2. Create the RabbitMQ credentials secret:
```bash
# Generate a secure password and Erlang cookie
export RABBITMQ_PASSWORD=$(openssl rand -base64 32)
export ERLANG_COOKIE=$(openssl rand -hex 16)

kubectl create secret generic rabbitmq \
  --namespace biomed \
  --from-literal=rabbitmq-password="$RABBITMQ_PASSWORD" \
  --from-literal=rabbitmq-erlang-cookie="$ERLANG_COOKIE"
```

3. Install the chart:
```bash
helm upgrade --install rabbitmq . -n biomed --create-namespace
```

Access

Get the RabbitMQ credentials:
```bash
export RABBIT_USER=$(kubectl get secret --namespace biomed rabbitmq -o jsonpath="{.data.rabbitmq-password}" | base64 -d)
```

Port-forward management UI:
```bash
kubectl port-forward --namespace biomed svc/rabbitmq 15672:15672
```

Notes / Missing items when deploying from `docker-compose.yml`

- StorageClass: ensure the `storageClass` in `values.yaml` exists in your cluster or set it to `""` for the cluster default.
- Secrets: the Bitnami chart will create secrets from `auth` values; for production, prefer supplying Kubernetes `Secret`s and referencing them.
- HA settings: `replicaCount` > 1 requires clustering setup and appropriate `erlangCookie` configuration.
- Resources: tune `resources` and `persistence.size` for your workload.
