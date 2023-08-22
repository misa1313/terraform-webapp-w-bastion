#!/bin/bash

sudo dnf upgrade --releasever=2023.1.20230809 -y
sudo dnf install python3-pip -y
sudo pip3 install ansible
aws s3 cp s3://apache-buck-04/setup-play.yaml /home/ec2-user/setup-play.yaml
aws s3 cp s3://apache-buck-04/index.html /home/ec2-user/index.html
sudo ansible-playbook /home/ec2-user/setup-play.yaml