# Argo Workflow Templates Helm Chart

This Helm chart manages the deployment of Argo `WorkflowTemplate` resources. Instead of defining templates directly
inside Helm templates with complex variable substitution, this chart uses a **generator pattern**. It reads raw Argo
YAML definitions from the `definitions/` directory and wraps them with standard Kubernetes metadata, labels, and
environment configurations.

## 📂 Directory Structure

```text
_k8s/helm/workflow-templates/
├── Chart.yaml                  # Chart metadata and version
├── values.yaml                 # Configuration values
├── definitions/
│   ├── templates/              # Place your standard WorkflowTemplate YAMLs here
└── templates/
    └── templates-generator.yaml # Logic to generate manifests from definitions
```

## 🚀 How it Works

### The Generator Pattern

The file `templates/templates-generator.yaml` iterates over files found in `definitions/templates/*.yaml`. For every
file found, it:

1. Parses the raw YAML content.
2. Injects standard labels (e.g., `environment`, `managed-by`).
3. Generates a valid Kubernetes manifest in the target namespace.

## ⚙️ Configuration (`values.yaml`)

| Key                       | Type   | Default | Description                                                     |
|---------------------------|--------|---------|-----------------------------------------------------------------|
| `environment`             | string | `dev`   | The target environment (e.g., `dev`, `prod`). Added as a label. |
| `types.templates.enabled` | bool   | `true`  | Enables generation of standard `WorkflowTemplate` resources.    |

## 🛠 Adding a New Workflow

1. Create a new YAML file in `definitions/templates/` (e.g., `my-process.yaml`).
2. Define the `WorkflowTemplate` as usual. You do **not** need to add Helm templating syntax (`{{ ... }}`) inside this
   file.
3. Add a template-version label to the `WorkflowTemplate` metadata, for example:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: my-process
  namespace: argo-managed-crawler
  labels:
    template-version: "2.1.0"
spec:
  entrypoint: main
  templates:
    - name: main
      container:
        image: alpine:latest
        command: [echo, "Hello World"]
```

## 📦 Deployment

### CI/CD (GitHub Actions)

The deployment pipeline automatically scans the `definitions/templates` folder and populates all available templates 
for deployment.

### Manual Deployment

```bash
helm upgrade --install workflow-templates . \
  --namespace argo-managed-crawler \
  --create-namespace \
  --set environment=dev
```