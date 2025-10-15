#!/bin/bash
# ============================================
# GCP VM Readiness Script
# Project: lustrous-drake-412814
# Author: ChatGPT
# ============================================

set -e

PROJECT_ID="lustrous-drake-412814"
TERRAFORM_VERSION="1.6.6"

echo "============================================"
echo " 🚀 Starting VM Readiness Setup"
echo "============================================"

# ---- Update System ----
echo "[1/7] Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# ---- Install Prerequisites ----
echo "[2/7] Installing required packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common unzip

# ---- Install gcloud CLI ----
if ! command -v gcloud &>/dev/null; then
  echo "[3/7] Installing Google Cloud SDK..."
  echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" \
    | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
    | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
  sudo apt-get update -y && sudo apt-get install -y google-cloud-sdk
else
  echo "✅ gcloud already installed."
fi

# ---- Authenticate and set project ----
echo "[4/7] Authenticating with gcloud..."
gcloud auth list || true
gcloud auth login --brief || true
gcloud config set project $PROJECT_ID

# ---- Install Terraform ----
if ! command -v terraform &>/dev/null; then
  echo "[5/7] Installing Terraform v$TERRAFORM_VERSION..."
  curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip
  sudo unzip -o terraform.zip -d /usr/local/bin/
  rm terraform.zip
else
  echo "✅ Terraform already installed."
fi

# ---- Install Docker ----
if ! command -v docker &>/dev/null; then
  echo "[6/7] Installing Docker..."
  sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker $USER
else
  echo "✅ Docker already installed."
fi

# ---- Install Git ----
if ! command -v git &>/dev/null; then
  echo "[7/7] Installing Git..."
  sudo apt-get install -y git
else
  echo "✅ Git already installed."
fi

# ---- Verification ----
echo "============================================"
echo " 🔍 Verifying installations..."
echo "--------------------------------------------"
gcloud version | head -n 1
terraform -version | head -n 1
docker --version
git --version
echo "--------------------------------------------"

echo "✅ VM is ready for GCP Terraform + Docker + Git environment!"
echo "============================================"
echo "You may need to log out and log back in for Docker permissions to take effect."
echo "============================================"
