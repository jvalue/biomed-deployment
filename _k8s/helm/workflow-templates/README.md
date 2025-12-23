# Argo Workflow Templates Helm Chart

This Helm chart manages the deployment of Argo `WorkflowTemplate` resources. Instead of defining templates directly
inside Helm templates with complex variable substitution, this chart uses a **generator pattern**. It reads raw Argo
YAML definitions from the `definitions/` directory and wraps them with standard Kubernetes metadata, labels, and
environment configurations.

## 📂 Directory Structure

```text
_k8s/helm/workflow-templates/
├── Chart.yaml                  # Chart metadata and default version
├── values.yaml                 # Configuration values
├── definitions/
│   ├── templates/              # Place your standard WorkflowTemplate YAMLs here
│   └── cron/                   # (Future) Place CronWorkflow YAMLs here
└── templates/
    └── templates-generator.yaml # Logic to generate manifests from definitions
```

## 🚀 How it Works

### The Generator Pattern

The file `templates/templates-generator.yaml` iterates over files found in `definitions/templates/*.yaml`. For every
file found, it:

1. Checks if the file is allowed via the `deployFilter` (passed by CI/CD).
2. Parses the raw YAML content.
3. Injects standard labels (e.g., `environment`, `managed-by`).
5. Generates a valid Kubernetes manifest in the target namespace.

## ⚙️ Configuration (`values.yaml`)

| Key                       | Type   | Default | Description                                                                    |
|---------------------------|--------|---------|--------------------------------------------------------------------------------|
| `environment`             | string | `dev`   | The target environment (e.g., `dev`, `prod`). Added as a label.                |
| `deployFilter`            | string | `""`    | **Required.** Comma-separated list of filenames (without extension) to deploy. |
| `types.templates.enabled` | bool   | `true`  | Enables generation of standard `WorkflowTemplate` resources.                   |
| `types.cron.enabled`      | bool   | `false` | Enables generation of `CronWorkflow` resources (for future use).               |

## 🛠 Adding a New Workflow

1. Create a new YAML file in `definitions/templates/` (e.g., `my-process.yaml`).
2. Define the `WorkflowTemplate` as usual. You do **not** need to add Helm templating syntax (`{{ ... }}`) inside this
   file.
3. Add a version label

```yaml
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: my-process
  namespace: argo-managed-crawler
  labels:
    version: "2.1.0"
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

The deployment pipeline automatically scans the `definitions/templates` folder and populates the `deployFilter`.

### Manual Deployment

To deploy manually, you must provide the `deployFilter` to tell Helm which files to process.

```bash
# 1. Generate the list of templates
TEMPLATES=$(ls definitions/templates/*.yaml | xargs -n 1 basename | sed 's/\.yaml$//' | paste -sd "," -)

# 2. Run Helm Upgrade
helm upgrade --install workflow-templates . \
  --namespace argo-managed-crawler \
  --create-namespace \
  --set environment=dev \
  --set deployFilter="$TEMPLATES"
```