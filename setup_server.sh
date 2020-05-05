#!/usr/bin/env bash
source tools.sh

set -o nounset

function setup_docker {
  if $(missing "docker"); then
    info "Getting prerequirements..."
    apt-get update && apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common

    info "Getting pgp key..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

    add-apt-repository \
       "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
       $(lsb_release -cs) \
       stable"

    apt-get update
    info "Installing..."
    apt-get install docker-ce docker-ce-cli containerd.io -y
  else
    info "Docker installed..."
  fi
}


function setup_ufw {
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow 80
  sudo ufw allow 443
  sudo ufw allow 22
  sudo ufw enable
}


declare -a setups=(
  "setup_docker"
  "setup_ufw"
)

for setup in ${setups[@]}; do
  item "$(random_color)" $setup
done

set +o nounset

info "✨ All done!"