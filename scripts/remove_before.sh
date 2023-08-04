#!/bin/bash 

find /opt/codedeploy-agent/deployment-root/334c4da0-0a61-47a0-8e33-4e4037a8e2d6/* -maxdepth 0 -type 'd' | grep -v $(stat -c '%Y:%n' /opt/codedeploy-agent/deployment-root/334c4da0-0a61-47a0-8e33-4e4037a8e2d6/* | sort -t: -n | tail -1 | cut -d: -f2- | cut -c 3-) | xargs rm -rf sudo rm -rf /home/ubuntu/*
