#!/bin/bash -e

## Let's do some verifications before running the script...

# Is this script OK for your distribution?
if [[ $(lsb_release -d) =~ "Ubuntu" ]]; then
  :
else
  echo "This package is not suitable for your distribution. Please use it with Ubuntu only or download the right script.";
  exit 0;
fi

# Verify that the user has enough permissions to run the script
if [[ $EUID != 0 ]]; then
  while true; do
    read -p "Would you like the script to be run with sudo? (y/n) " sudo_param
    case $sudo_param in
      [yY]*) sudo $0 ; break;;
      [nN]*) echo "You have to run this program with root permissions. Exiting program" && exit 0;;
      *) echo "Please answer 'yes' or 'no'";;
    esac
  done
fi

## Let's prepare requirements for Storj

read -p "Storage Node name: " node_name
if [[ -z $node_name ]]; then
  node_name="storagenode"
fi

read -p "Storagenode port (default: 28967): " node_port
if [[ -z $node_port ]]; then
  node_port=28967
fi

read -p "Storagenode GUI dashboard port (default: 14002): " dashboard_port
if [[ -z $dashboard_port ]]; then
  dashboard_port=14002
fi

while true; do
  read -p "Wallet address: " wallet_address
  if [[ -n $wallet_address ]]; then
    break ;
  else
    :
  fi
done

while true; do
  read -p "Email address: " email
  if [[ -n $email ]]; then
    break ;
  else
    :
  fi
done

while true; do
  read -p "Public IP or DNS address: " ip_address
  if [[ -n $ip_address ]]; then
    break ;
  else
    :
  fi
done

while true; do
  read -p "Do you already have an identity (y/n) " answer
  case $answer in
    [yY]*) read -p "Identity location: " identity_location && identity_creation="no" ; break;;
    [nN]*) identity_creation="yes" ; break;;
    *) echo "Please answer 'yes' or 'no'";;
  esac
done

while true; do
  read -p "Do you already have an identity (y/n) " answer
  case $answer in
    [yY]*) read -p "Identity location: " identity_location && identity_creation="no" ; break;;
    [nN]*) identity_creation="yes" ; break;;
    *) echo "Please answer 'yes' or 'no'";;
  esac
done

# Prepare Identity

if [[ identity_creation == "yes" ]]; then
  echo "Installation of useful packages..."
  apt update && apt install -y curl unzip

  curl -L https://github.com/storj/storj/releases/latest/download/identity_linux_amd64.zip -o /tmp/identity_linux_amd64.zip
  unzip -o /tmp/identity_linux_amd64.zip
  chmod +x identity
  mv identity /usr/local/bin/identity

  identity create $node_name --config-dir ./identity/$node_name
elif [[ identity_creation =="no" ]]; then
  :
fi

## Create the container
apt update && apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt -y install docker-ce docker-ce-cli containerd.io

## Recap

exit 0
