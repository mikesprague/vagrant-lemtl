#!/bin/bash

echo "================= START INSTALL-TOMCAT.SH $(date +"%r") ================="
echo " "
echo "BEGIN setting up Tomcat and misc. utilities ..."

# a little housekeeping
echo "... Doing a little housekeeping ..."
sudo apt-get -y autoremove > /dev/null
sudo apt-get -y update --fix-missing > /dev/null

# install some common utilities
if [ ! -f /var/log/utils_installed ]; then
	echo "... Installing misc. utilities ..."

	sudo apt-get -y update > /dev/null
	sudo apt-get -qq install wget curl zip unzip debconf-utils > /dev/null

	touch /var/log/utils_installed
fi

# install java, openssl, and tomcat7
if [ ! -d "/etc/tomcat7" ]; then
	echo "... Installing Tomcat (grab a cup of coffee, this may take a few minutes) ..."

	sudo apt-get -y update > /dev/null
	sudo apt-get -qq install tomcat7 > /dev/null
fi

# copy modified server.xml to the vm
sudo cp /vagrant/configs/server.xml /etc/tomcat7/server.xml

# copy modified catalina.properties to the vm
sudo cp /vagrant/configs/catalina.properties /etc/tomcat7/catalina.properties

# copy setenv.sh to the vm
sudo cp /vagrant/configs/setenv.sh /usr/share/tomcat7/bin/setenv.sh

# restart tomcat
sudo service tomcat7 restart > /dev/null

# install iptables
echo "... Installing iptables and configuring port forwarding ..."
sudo apt-get -y update > /dev/null
sudo apt-get -qq install iptables > /dev/null

# configure iptables to forward incoming requests on port 80 to port 8080 so they hit tomcat
sudo iptables -t nat -I PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080 > /dev/null

# restart tocat
sudo service tomcat7 restart > /dev/null

echo "... END setting up Tomcat and misc. utilities."
echo " "
echo "================= FINISH INSTALL-TOMCAT.SH $(date +"%r") ================="
echo " "
echo "$1"
echo " "
echo "========================================================================"
echo " "
echo "http://$2 ($3)"
echo " "
echo "Railo Server/Web Context Administrators"
echo " "
echo "http://$2/railo-context/admin/server.cfm"
echo "http://$2/railo-context/admin/web.cfm"
echo "Password (for each admin): password"
echo " "
echo " "
echo "MySQL Connection Info for External Connections (use localhost inside vm)"
echo " "
echo "Server: $4"
echo "Port: 3306"
echo "User: root"
echo "Password: password"
echo " "
echo "========================================================================"
