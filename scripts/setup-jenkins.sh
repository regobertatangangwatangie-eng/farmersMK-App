#!/bin/bash
set -e

echo "=== Installing prerequisites ==="
if command -v dnf &>/dev/null; then
  sudo dnf install -y java-21-amazon-corretto-headless git maven docker 2>&1 | tail -3
elif command -v yum &>/dev/null; then
  sudo yum install -y java-21-amazon-corretto-headless git maven docker 2>&1 | tail -3
else
  sudo apt-get update -q && sudo apt-get install -y openjdk-21-jdk-headless git maven docker.io 2>&1 | tail -3
fi
java -version 2>&1

echo "=== Installing Jenkins ==="
if command -v dnf &>/dev/null || command -v yum &>/dev/null; then
  sudo curl -fsSL -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
  sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
  sudo dnf install -y jenkins 2>&1 | tail -3 || sudo yum install -y jenkins 2>&1 | tail -3
else
  curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
  echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
  sudo apt-get update -q && sudo apt-get install -y jenkins 2>&1 | tail -3
fi

echo "=== Enabling Docker + Jenkins ==="
sudo systemctl enable docker jenkins
sudo systemctl start docker jenkins
sudo usermod -aG docker jenkins
sudo usermod -aG docker ec2-user

echo "=== Waiting for Jenkins to start (up to 90s) ==="
for i in $(seq 1 18); do
  if curl -sf http://localhost:8080/login -o /dev/null 2>/dev/null; then
    echo "Jenkins is UP!"
    break
  fi
  echo "  Waiting... ($((i*5))s)"
  sleep 5
done

echo "=== Initial admin password ==="
sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Password not found yet"
echo "=== Jenkins setup complete ==="
