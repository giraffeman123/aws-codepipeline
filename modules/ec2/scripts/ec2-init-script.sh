#!/bin/bash

#Instalacion paquetes necesarios
sudo apt-get update
sudo apt -y install npm

#install, configure and start code-deploy agent
sudo apt-get install ruby -y
sudo apt-get install wget -y
wget https://aws-codedeploy-ca-central-1.s3.ca-central-1.amazonaws.com/latest/install
chmod +x ./install
sudo ./install auto 
sudo service codedeploy-agent status