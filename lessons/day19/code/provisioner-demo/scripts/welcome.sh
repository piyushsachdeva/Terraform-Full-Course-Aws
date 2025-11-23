#!/bin/bash
# A simple script copied to the instance during the file+remote-exec demo
set -e

echo "Welcome to the Provisioner Demo" | sudo tee /tmp/welcome_msg.txt
uname -a | sudo tee -a /tmp/welcome_msg.txt
cat /tmp/welcome_msg.txt
