# Keycloak Monitoring with Prometheus and Grafana on AKS

## Overview

This README outlines the process for monitoring Keycloak using Prometheus and Grafana on Azure Kubernetes Service (AKS). The setup includes deploying Keycloak with custom configurations to expose metrics, configuring Prometheus for metrics scraping, and setting up Grafana for visualization.

## Prerequisites

- Azure CLI installed
- Kubernetes CLI (kubectl) installed
- Helm 3 installed
- Terraform installed and configured

## Setup Steps

### 1. Clone the repository

Start by cloning the repository and navigate to the project directory:
```bash
git clone [repository-url]
cd [repository-directory]
```

### 2. Create an AKS Cluster using Terraform

Navigate to the Terraform directory and apply the Terraform scripts to set up the infrastructure:
```bash
cd terraform
terraform init
terraform apply --auto-approve
```
This command will create a resource group named `myResource` and a single-node AKS cluster named `myCluster`.

### 3. Configure kubectl

Connect `kubectl` to your newly created AKS cluster:
```bash
az aks get-credentials --resource-group myResource --name myCluster --overwrite-existing
```

### 4. Create a Kubernetes Namespace

Create a namespace for your deployments to organize resources:
```bash
kubectl create namespace my-namespace
```

### 5. Configure Keycloak for Prometheus Scraping

We have modified `keycloak/values.yaml` to include Prometheus scrape annotations and labels:
```yaml
## Add pod annotations for Prometheus scraping
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  prometheus.io/path: "/realms/master/metrics"

## Metrics configuration
extraEnv:
  - name: KC_METRICS_ENABLED
    value: "true"

## Add podLabels for Prometheus service discovery
podLabels:
  app: keycloak
```

### 6. Deploy Keycloak using Helm

Deploy Keycloak with the modified `values.yaml`:
```bash
helm install my-keycloak bitnami/keycloak --namespace my-namespace --version 20.0.1 -f keycloak/values.yaml
```

### 7. Enable Metrics Listener in Keycloak

Enable the metrics listener from the Keycloak admin console:
- Navigate to **Manage -> Events -> Config** in the Keycloak admin panel.
- Add `metrics-listener` to Event Listeners.
- **Note**: This step needs to be repeated for every realm.

### 8. Configure Prometheus for Scraping

We have modified `prometheus/values.yaml` to set up scraping of Keycloak metrics and deploy Prometheus:
```yaml
scrape_configs:
  - job_name: 'keycloak'
    kubernetes_sd_configs:
      - role: pod  
        namespaces:
          names:
            - my-namespace 
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app] 
        action: keep
        regex: keycloak  
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true  
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
        replacement: $1  
      - source_labels: [__address__, __meta_kubernetes_pod_annotation_prometheus_io_port]
        action: replace
        target_label: __address__
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2  
```

### 9. Install Prometheus

Install Prometheus using Helm:
```bash
helm install my-prometheus prometheus-community/prometheus --namespace my-namespace -f prometheus/values.yaml
```

### 10. Install and Configure Grafana

Deploy Grafana and configure it to use Prometheus as the data source:
```bash
helm install my-grafana grafana/grafana --namespace my-namespace
```
- Navigate to **Configuration -> Data Sources** in Grafana.
- Add Prometheus as a data source.
- Import the Keycloak dashboard with ID `19659`.

## Verification

Check that Prometheus is successfully scraping metrics from Keycloak and that Grafana displays these metrics on the dashboard.

## Conclusion

Your Keycloak instance is now being monitored with Prometheus and Grafana. This setup allows for efficient visualization and management of Keycloak's performance metrics, enhancing your ability to maintain and optimize the system.
