#!/bin/bash

echo "================= START STEP-2-INSTALL-UTILITIES.SH $(date +"%r") ================="
echo " "
echo "BEGIN installing utilities"

# install some common utilities
if [ ! -f /var/log/utils_installed ]; then
	echo "... Installing miscellaneous/common utilities ..."

  sudo apt-add-repository -y ppa:webupd8team/java > /dev/null
  sudo apt-get -y update > /dev/null
  sudo apt-get -y install oracle-java8-installer > /dev/null

	sudo apt-get -qq install wget > /dev/null
	sudo apt-get -qq install curl > /dev/null
	sudo apt-get -qq install zip > /dev/null
	sudo apt-get -qq install unzip > /dev/null
	sudo apt-get -qq install iptables > /dev/null
	sudo apt-get -qq install debconf-utils > /dev/null
	sudo apt-get -qq install software-properties-common > /dev/null

	touch /var/log/utils_installed
fi

echo "... END installing utilities."
echo " "
echo "================= FINISH STEP-2-INSTALL-UTILITIES.SH $(date +"%r") ================="
echo " "
