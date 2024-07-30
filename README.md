# Keycloak Monitoring with Prometheus and Grafana on AKS

## Overview

This README outlines the setup process for monitoring Keycloak using Prometheus and Grafana on Azure Kubernetes Service (AKS). The setup includes deploying Keycloak with a custom Docker image to expose metrics, and configuring Prometheus and Grafana for visualization.

## Prerequisites

- Azure CLI
- Kubernetes CLI (kubectl)
- Helm 3
- Docker installed and configured
- Terraform installed and configured

## Setup Steps

### 1. Clone the repository

Clone the repository and navigate to the project directory:

```bash
git clone <repository-url>
cd <project-directory>
```

### 2. Create AKS Cluster using Terraform

Navigate to the Terraform directory and apply the Terraform scripts:

```bash
cd terraform
terraform init
terraform apply --auto-approve
```

### 3. Configure kubectl

Connect kubectl to your AKS cluster:

```bash
az aks get-credentials --resource-group myResource --name myCluster --overwrite-existing
```

### 4. Create Kubernetes Namespace

Create a namespace for your deployments:

```bash
kubectl create namespace my-namespace
```

### 5. Deploy Keycloak

Deploy Keycloak using Helm with the custom values.yaml:

```bash
helm install my-keycloak bitnami/keycloak --namespace my-namespace --version 20.0.1 -f keycloak/values.yaml
```

### Custom Docker Image for Keycloak

Here's the Dockerfile for the Keycloak image which includes the SPI to expose metrics:

```Dockerfile
FROM docker.io/bitnami/keycloak:23.0.7-debian-12-r4
# Add custom SPI jar
COPY ./keycloak-metrics-spi-5.0.0.jar /opt/keycloak/providers/
```

### 6. Enable Metrics in Keycloak

Access Keycloak admin console and enable the metrics listener:

- Navigate to **Manage -> Events -> Config** and add `metrics-listener` in Event Listeners.

### 7. Install Prometheus

Modify `prometheus/values.yaml` for Keycloak metrics scraping and install Prometheus:

```yaml
scrape_configs:
  - job_name: 'keycloak'
    metrics_path: '/realms/master/metrics'
    scheme: 'http'
    static_configs:
      - targets: ['<keycloak-service-ip>:<port>']
```

Install Prometheus with Helm:

```bash
helm install my-prometheus prometheus-community/prometheus --namespace my-namespace -f prometheus/values.yaml
```

### 8. Install Grafana

Deploy Grafana:

```bash
helm install my-grafana grafana/grafana --namespace my-namespace
```

### 9. Configure Grafana

Configure Grafana to use Prometheus as a data source and import the Keycloak dashboard:

- Access Grafana, navigate to **Configuration -> Data Sources** and add Prometheus.
- Import dashboard with ID `10441`.

## Verification

Ensure that Prometheus successfully scrapes metrics from Keycloak and that Grafana displays these metrics.

## Conclusion

Your Keycloak instance is now being monitored with Prometheus and Grafana. This setup allows you to visualize and manage Keycloak's performance metrics efficiently.
```

Please ensure to replace `<repository-url>`, `<project-directory>`, and `<keycloak-service-ip>:<port>` with actual values relevant to your setup. This README file is structured in Markdown format, specifically designed for GitHub and similar platforms, and includes all the code blocks and formatting necessary for clear instructions.
