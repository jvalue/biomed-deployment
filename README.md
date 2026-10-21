# README - Argo Workflows Setup & Usage

## 1. Folder Structure
- `_k8s/helm/`: Helm chart for Argo Workflows deployment
- `_k8s/helm/workflow-templates/`: Helm chart for Argo WorkflowTemplates deployment

# 2. Argo Workflows Usage
We will develop our own UI, but as long as it is not ready, we can use the Argo Workflows UI and API directly.

The Argo Workflows server is deployed with `client` authentication mode, meaning every request must include a Kubernetes ServiceAccount token.
This token is also used for login to the UI.

You can retrieve it the following way:
There is a ServiceAccount with full access to workflows called `argo-user` in the `argo` namespace.

To interact with the cluster you have to export your KubeConfig first:

For Mac/Linux:
```bash
export KUBECONFIG=<path-to-your-kubeconfig>
```

For Windows (PowerShell):
```powershell
$env:KUBECONFIG="<path-to-your-kubeconfig>"
```

Then you can get the token with:
```bash
kubectl -n argo create token argo-user 
```

Now open the Argo UI in your browser and paste the token into the login dialog:
```
http://<argo-server-host>/argo
```