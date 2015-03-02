#!/bin/bash

echo "================= START STEP-3-INSTALL-TOMCAT.SH $(date +"%r") ================="
echo " "
echo "BEGIN setting up Tomcat"

# install tomcat7
if [ ! -d "/etc/tomcat7" ]; then
	echo "... Installing Tomcat (grab a cup of coffee, this may take a few minutes) ..."
	sudo apt-get -y install tomcat7 > /dev/null
fi

echo "... Configuring Tomcat ..."
# copy modified server.xml to the vm
sudo cp /vagrant/configs/server.xml /etc/tomcat7/server.xml
# copy modified catalina.properties to the vm
sudo cp /vagrant/configs/catalina.properties /etc/tomcat7/catalina.properties
# copy setenv.sh to the vm
sudo cp /vagrant/configs/setenv.sh /usr/share/tomcat7/bin/setenv.sh
# restart tomcat
sudo service tomcat7 restart > /dev/null

echo "... END setting up Tomcat."
echo " "
echo "================= FINISH STEP-3-INSTALL-TOMCAT.SH $(date +"%r") ================="
echo " "
