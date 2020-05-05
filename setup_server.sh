#!/usr/bin/env bash
source tools.sh

set -o nounset
set -o errexit

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
    systemctl enable docker
  else
    info "Docker installed..."
  fi
}

function setup_docker_compose {
  if $(missing "docker-compose"); then
    info "Getting docker-compose..."
    curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
  else
    info "Docker Compose is installed..."
  fi
}


function setup_standardnotes {
  info "Setting up requirements for standardnotes..."

  dpkg -l libmysqlclient-dev 2>&1 > /dev/null
  if [[ $? -ne 0 ]]; then
    info "Installing libsqlclient-dev..."
    apt-get update && apt-get install libmysqlclient-dev -y
  else
    info "libmysqlclient-dev exists..."
  fi

  if $(missing "ruby"); then
    info "Installing ruby..."
    apt-get update && apt-get install ruby-full=1:2.5.1 -y
    ln -s /usr/bin/ruby2.5 /usr/bin/ruby
    ln -s /usr/bin/gem2.5 /usr/bin/gem
  else
    info "Ruby installed..."
  fi

  if [[ ! -d  /opt/syncing-server ]]; then
    cd /opt
    git clone https://github.com/standardnotes/syncing-server.git
    cd syncing-server
    gem install bundler
    bundle install
    info "Please copy .env.sample to .env and update it before launching."
    info "Then run: docker-compose up -d"
  else
    info "Syncing server exists..."
  fi

}


function setup_ufw {
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow 80
  ufw allow 443
  ufw allow 22
  echo "Please run: ufw enable"
}


declare -a setups=(
  "setup_docker"
  "setup_docker_compose"
  "setup_standardnotes"
  "setup_ufw"
)

for setup in ${setups[@]}; do
  item "$(random_color)" $setup
done

set +o nounset

info "✨ All done!"
