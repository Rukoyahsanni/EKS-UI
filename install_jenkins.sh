#!/bin/bash
sudo apt-get update -y
sudo apt-get install openjdk-17-jre-headless -y
sudo apt-get install -y ca-certificates curl gnupg
sudo apt-get update -y
sudo apt-get install maven -y
sudo apt-get update -y
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
  sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y jenkins
sudo systemctl daemon-reload
sudo systemctl enable Jenkins
sudo systemctl start Jenkins
sudo systemctl status Jenkins
sudo apt-get update -y
sudo apt-get install -y wget unzip
wget https://releases.hashicorp.com/terraform/1.10.5/terraform_1.10.5_linux_amd64.zip
unzip terraform_1.10.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu
sudo usermod -aG docker $USER
curl -LO https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
chmod +x kubectl
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
sudo apt-get install -y apt-transport-https
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update -y
sudo apt-get install -y kubectl=1.21.0-00
sudo apt install awscli -y
wget https://get.helm.sh/helm-v3.2.4-linux-amd64.tar.gz
tar -zxvf helm-v3.2.4-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
echo 'clearing screen...' && sleep 5
clear
echo 'jenkins is installed'
echo 'this is the default password :' $(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)