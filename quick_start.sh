#!/usr/bin/env bash
#

Version=v0.0.1

function install_soft() {
    if command -v dnf > /dev/null; then
      dnf -q -y install "$1"
    elif command -v yum > /dev/null; then
      yum -q -y install "$1"
    elif command -v apt > /dev/null; then
      apt-get -qqy install "$1"
    elif command -v zypper > /dev/null; then
      zypper -q -n install "$1"
    elif command -v apk > /dev/null; then
      apk add -q "$1"
      command -v gettext >/dev/null || {
      apk add -q gettext-dev python3
    }
    else
      echo -e "[\033[31m ERROR \033[0m] $1 command not found, Please install it first"
      exit 1
    fi
}

function prepare_install() {
  for i in curl wget tar iptables; do
    command -v $i &>/dev/null || install_soft $i
  done
}

function get_installer() {
  echo "download install script to /opt/zqserver-installer-${ }"
  cd /opt || exit 1
  if [ ! -d "/opt/zqserver-installer-${Version}" ]; then
    timeout 60 wget -qO zqserver-installer-${Version}.tar.gz https://github.com/zqgkkj/installer/releases/download/${Version}/zqserver-installer-${Version}.tar.gz || {
      rm -f /opt/zqserver-installer-${Version}.tar.gz
      echo -e "[\033[31m ERROR \033[0m] Failed to download zqserver-installer-${Version}"
      exit 1
    }
    tar -xf /opt/zqserver-installer-${Version}.tar.gz -C /opt || {
      rm -rf /opt/zqserver-installer-${Version}
      echo -e "[\033[31m ERROR \033[0m] Failed to unzip zqserver-installer-${Version}"
      exit 1
    }
    rm -f /opt/zqserver-installer-${Version}.tar.gz
  fi
}

function config_installer() {
  cd /opt/zqserver-installer-${Version} || exit 1
  sed -i "s/VERSION=.*/VERSION=${Version}/g" /opt/zqserver-installer-${Version}/static.env
  ./jmsctl.sh install
  ./jmsctl.sh start
}

function main(){
  if [[ "${OS}" == 'Darwin' ]]; then
    echo
    echo "Unsupported Operating System Error"
    echo "macOS installer please see: https://github.com/zqserver/Dockerfile"
    exit 1
  fi
  prepare_install
  get_installer
  config_installer
}

main
