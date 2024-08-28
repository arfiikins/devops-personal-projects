#!/bin/bash

# do logging
exec > /var/log/dockerinstall.log 2>&1

install_docker() {
  echo "Installing Docker Engine using APT repository..."
  sleep 5

  # Add Docker's official GPG key:
  echo "Adding Docker's official GPG key..."
  sudo apt-get update -y
  sudo apt-get install ca-certificates curl -y
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "Adding Docker's official GPG key... Completed..."
  sleep 5

  # Add the repository to Apt sources:
  echo "Adding the repository to apt resources..."
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -y
  echo "Adding the repository to apt resources... Completed..."
  sleep 5

  # Install the Docker packages
  echo "Installing Docker packages..."
  sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
  echo "Installation completed!"

  # Check if Docker Engine installed successfully by running hello-world image
  echo "Running hello-world image to verify if Docker Engine is installed correctly..."
  sudo docker run hello-world

  echo "==================================="
  echo "===Script execution is finished!==="
  echo "==================================="
}

# Check if the OS is Ubuntu
if grep -q "Ubuntu" /etc/os-release; then
    echo "Operating System is Ubuntu. Proceeding with the script..."

    install_docker

else
    echo "This script is only compatible with Ubuntu. Exiting..."
    exit 1
fi