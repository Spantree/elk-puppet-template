#!/bin/bash

SCRIPT_ROOT=$(echo "$1")

OS=$(/bin/bash $SCRIPT_ROOT/os-detect.sh ID)
CODENAME=$(/bin/bash $SCRIPT_ROOT/os-detect.sh CODENAME)

if [[ ! -d /var/puppet-init/ ]]; then
    mkdir /var/puppet-init
    echo "Created directory /var/puppet-init"

    if [ "$OS" == 'debian' ] || [ "$OS" == 'ubuntu' ]; then
        sed -i 's/^mesg n$/tty -s \&\& mesg n/g' /root/.profile
    fi
fi

if [[ ! -f /var/puppet-init/initial-setup-repo-update ]]; then
    if [ "$OS" == 'debian' ] || [ "$OS" == 'ubuntu' ]; then
        echo "Running initial-setup apt-get update"
        apt-get update >/dev/null
        touch /var/puppet-init/initial-setup-repo-update
        echo "Finished running initial-setup apt-get update"
    elif [[ "$OS" == 'centos' ]]; then
        echo "Running initial-setup yum update"
        yum update -y >/dev/null
        echo "Finished running initial-setup yum update"

        echo "Installing basic development tools (CentOS)"
        yum -y groupinstall "Development Tools" >/dev/null
        echo "Finished installing basic development tools (CentOS)"
        touch /var/puppet-init/initial-setup-repo-update
    fi
fi

if [[ "$OS" == 'ubuntu' && ("$CODENAME" == 'lucid' || "$CODENAME" == 'precise') && ! -f /var/puppet-init/ubuntu-required-libraries ]]; then
    echo 'Installing basic curl packages (Ubuntu only)'
    apt-get install -y curl unzip libcurl3 libcurl4-gnutls-dev >/dev/null
    echo 'Finished installing basic curl packages (Ubuntu only)'

    touch /var/puppet-init/ubuntu-required-libraries
fi