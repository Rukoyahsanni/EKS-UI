#!/bin/bash
set -e  # Exit on error

echo "🟡 Updating package list and installing base dependencies..."
sudo apt-get update -y
sudo apt-get install -y openjdk-17-jre-headless ca-certificates curl gnupg wget unzip apt-transport-https software-properties-common

echo "🟡 Installing Maven..."
sudo apt-get install -y maven

echo "🟡 Adding Jenkins APT repository..."
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
echo "🟢 Installing Jenkins..."
sudo apt-get install -y jenkins
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "🟡 Setting up Docker repository..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc || true

# Ensure keyring directory exists
sudo mkdir -p /etc/apt/keyrings

# Download Docker GPG key and save in correct format
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker's official repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

echo "🟢 Installing Docker..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add Jenkins and current user to docker group
sudo usermod -aG docker jenkins
sudo usermod -aG docker $USER

echo "🟡 Installing Terraform v1.10.5..."
wget https://releases.hashicorp.com/terraform/1.10.5/terraform_1.10.5_linux_amd64.zip
unzip terraform_1.10.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.10.5_linux_amd64.zip

echo "🟡 Installing kubectl v1.32.3 (EKS compatible)..."
curl -LO https://dl.k8s.io/release/v1.32.3/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

echo "🟢 Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo "🟡 Installing Helm v3.14.3..."
wget https://get.helm.sh/helm-v3.14.3-linux-amd64.tar.gz
tar -zxvf helm-v3.14.3-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
rm -rf linux-amd64 helm-v3.14.3-linux-amd64.tar.gz

echo "✅ All tools installed successfully."
echo "🟢 Jenkins is running."
echo "🔐 Jenkins initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo "🟡 You may need to log out and back in for Docker group changes to take effect."
