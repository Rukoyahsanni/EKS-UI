#!/bin/bash

# Exit on any error
set -e

# System updates and required packages
sudo apt update -y && sudo apt upgrade -y
sudo apt install openjdk-17-jdk -y
sudo apt install postgresql postgresql-contrib unzip -y

# Setup SonarQube PostgreSQL user and DB
sudo -u postgres psql <<EOF
CREATE USER sonar WITH ENCRYPTED PASSWORD 'sonar';
CREATE DATABASE sonarqube OWNER sonar;
EOF

# Create sonar user
sudo useradd -m -d /opt/sonarqube -U -s /bin/bash sonar

echo "⬇️ Downloading SonarQube..."
SONAR_VERSION="10.4.1.88267"
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip
sudo unzip sonarqube-$SONAR_VERSION.zip
sudo mv sonarqube-$SONAR_VERSION/* /opt/sonarqube
sudo chown -R sonar: /opt/sonarqube

echo "🛠️ Configuring SonarQube to use PostgreSQL..."
sudo sed -i "s|#sonar.jdbc.username=|sonar.jdbc.username=sonar|" /opt/sonarqube/conf/sonar.properties
sudo sed -i "s|#sonar.jdbc.password=|sonar.jdbc.password=sonar|" /opt/sonarqube/conf/sonar.properties
echo "sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube" | sudo tee -a /opt/sonarqube/conf/sonar.properties

echo "🔧 Applying required system settings for Elasticsearch..."
sudo sysctl -w vm.max_map_count=262144
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

echo "🔧 Creating systemd service..."
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always
LimitNOFILE=65536
LimitNPROC=4096
TimeoutStartSec=60
TimeoutStopSec=60
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

echo "🚀 Starting SonarQube..."
sudo sed -i 's/\r//' /etc/systemd/system/sonarqube.service
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube

# Final login info
echo ""
echo "✅ SonarQube installation completed!"
echo "   ▶ Username: admin"
echo "   ▶ Password: admin"
echo "⚠️ Don't forget to change the admin password after first login."
