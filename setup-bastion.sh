#!/bin/bash

sudo dnf upgrade --releasever=2023.1.20230809 -y
sudo dnf install python3-pip -y
sudo dnf install telnet -y
pip3 install ansible
