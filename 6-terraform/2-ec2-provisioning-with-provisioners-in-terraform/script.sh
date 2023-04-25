#!/bin/bash

sudo apt update -y
sudo apt install -y docker.io
sudo systemctl start docker
sudo usermod -aG docker ubuntu
sudo chmod 777 /var/run/docker.sock
docker run -p 8080:80 --name nginx nginx
