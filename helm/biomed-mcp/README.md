# Biomed Unified MCP Server Helm Chart

Deploys the unified Biomed Model Context Protocol (MCP) server running over Server-Sent Events (SSE) in Kubernetes.

## Features

- Exposes 9 tools combining PostgreSQL (`xml-db`) and S3 (`minio`) data access.
- Runs in SSE transport mode (`MCP_TRANSPORT=sse`) on port 8004.
- In-process Strawberry GraphQL query execution with zero HTTP hop overhead.

## Installation

```bash
helm upgrade --install biomed-mcp ./helm/biomed-mcp -n argo-managed-crawler
```

## Verification

```bash
kubectl get pods -n argo-managed-crawler -l app.kubernetes.io/name=biomed-mcp
kubectl logs -n argo-managed-crawler -l app.kubernetes.io/name=biomed-mcp -f
```

## SSE Connection URL

Within cluster:
`http://biomed-mcp.argo-managed-crawler.svc.cluster.local:8004/sse`
