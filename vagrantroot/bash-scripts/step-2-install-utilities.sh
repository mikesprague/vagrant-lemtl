#!/bin/bash

echo "================= START STEP-2-INSTALL-UTILITIES.SH $(date +"%r") ================="
echo " "
echo "BEGIN installing utilities"

# install some common utilities
echo "... Installing miscellaneous/common utilities ..."

sudo apt-get -qq install wget > /dev/null
sudo apt-get -qq install curl > /dev/null
sudo apt-get -qq install zip > /dev/null
sudo apt-get -qq install unzip > /dev/null
sudo apt-get -qq install iptables > /dev/null
sudo apt-get -qq install debconf-utils > /dev/null
sudo apt-get -qq install software-properties-common > /dev/null

sudo add-apt-repository -y ppa:openjdk-r/ppa > /dev/null
sudo apt-get -y update > /dev/null
sudo apt-get -y install openjdk-8-jdk > /dev/null

echo "... END installing utilities."
echo " "
echo "================= FINISH STEP-2-INSTALL-UTILITIES.SH $(date +"%r") ================="
echo " "
