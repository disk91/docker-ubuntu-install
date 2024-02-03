#!/bin/bash

cecho() {
  echo -e "${COLORON}### $1${COLOROFF}"
}

# Install docker environement
DOCKER=0
if command -v docker >/dev/null 2>&1; then
  # we have docker, do we need to install ?
  if [ -f /etc/apt/keyrings/docker.gpg ] ; then
     # looks like the install we want
     DOCKER=1
  else
     # looks like a different install
     DOCKER=1
     read -p "Your Docker install seems different than the one expected, can we reinstall it [Y/N] ?" resp
     case $resp in
      [Yy] )
        for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get -y remove $pkg; done
        DOCKER=0
       ;;
     esac
  fi
fi
if [ $DOCKER -eq 0 ] ; then
  cecho "Installing Docker"
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  DEBIAN_FRONTEND=noninteractive apt update -qq >/dev/null 2>/dev/null
  DEBIAN_FRONTEND=noninteractive apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -qq >/dev/null
fi
