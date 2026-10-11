#!/usr/bin/env bash

# Simple deployment script for workflow templates
# Usage: ./deploy.sh

set -e

CHART_DIR="_k8s/helm/workflow-templates"
NAMESPACE="argo-managed-crawler"
RELEASE="workflow-templates"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Deploying Workflow Templates${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check dependencies
if ! command -v helm &> /dev/null; then
    echo -e "${RED}❌ helm not found${NC}"
    exit 1
fi

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl not found${NC}"
    exit 1
fi

echo -e "${YELLOW}Deploying:${NC} $CHART_DIR"
echo -e "${YELLOW}Namespace:${NC} $NAMESPACE"
echo -e "${YELLOW}Release:${NC} $RELEASE"
echo ""

# Deploy
if helm upgrade "$RELEASE" "$CHART_DIR" -n "$NAMESPACE"; then
    echo ""
    echo -e "${GREEN}✅ Deployment successful!${NC}"
    echo ""
    echo -e "${YELLOW}Updated templates:${NC}"
    kubectl get workflowtemplate crawler-general xml-ingestor-general -n "$NAMESPACE" \
        -o custom-columns=NAME:.metadata.name,VERSION:.metadata.labels."template-version",IMAGE:.spec.templates[0].container.image
else
    echo ""
    echo -e "${RED}❌ Deployment failed${NC}"
    exit 1
fi
