# k8s - Rendu Tom Avenel k8s

Ce projet regroupe plusieurs configurations Terraform et Kubernetes permettant de déployer une infrastructure cloud sur **Azure**, un cluster **K3s**, et un **serveur Nginx** sur Kubernetes.
L’ensemble est sécurisé par **HashiCorp Vault** pour la gestion des identifiants.

---

## 1. Terraform + Vault + Azure

### Description
Infrastructure Azure déployée via **Terraform**, avec stockage des identifiants dans **Vault**.
Aucune donnée sensible n’est enregistrée dans les fichiers `.tf` ou `.tfvars`.

### Contenu
- 3 VMs Debian 12 (2 Workers et 1 Control Plane)
- 1 Virtual Network + Subnet (un bridge est configuré sur le proxmox où c'est installé pour y avoir accès depuis mon poste).

### Commandes
```bash
# Initialisation
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='<token_vault>'
terraform init -upgrade

# Plan et déploiement
terraform plan
terraform apply -auto-approve
```

Secrets stockés dans Vault :
```
vault kv put terraform/azure   subscription_id="..."   client_id="..."   client_secret="..."   tenant_id="..."
```

---

## 2. Terraform K3s (Cluster Kubernetes)

### Description
Déploiement automatisé d’un **cluster K3s** local via Terraform.
Le cluster comprend un nœud **control-plane** et deux **workers** connectés sur un réseau interne VirtualBox.

### Commandes
```bash
# Control plane
curl -sfL https://get.k3s.io | sh -
sudo cat /var/lib/rancher/k3s/server/node-token

# Workers
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.10.109:6443 K3S_TOKEN=<token> sh -
```

### Vérification
```bash
kubectl get nodes -o wide
```
---

## 3. Déploiement Nginx sur Kubernetes

### Description
Déploiement d’un **serveur Nginx** sur le cluster K3s à l’aide de **Terraform Kubernetes provider**.

### Commandes
```bash
terraform init
terraform apply -auto-approve
kubectl get pods -n demo
kubectl get svc nginx-service -n demo
```

Accès web :
```
http://<IP_NODE>:30443
```
---

## Nettoyage global
```bash
terraform destroy -auto-approve
```
ou pour Kubernetes :
```bash
kubectl delete ns demo
```
