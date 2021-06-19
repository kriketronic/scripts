#!/bin/bash

groupadd docker
usermod -aG docker kike

timedatectl set-timezone America/Argentina/Buenos_Aires

apt-get update
