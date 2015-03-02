#!/bin/bash

echo "================= START STEP-4-INSTALL-NGINX.SH $(date +"%r") ================="
echo " "
echo "BEGIN installing and configuring nginx ..."

#install nginx
if [ ! -d "/etc/nginx" ]; then
	echo "Applying nginx/development repo and updating packages ..."
	sudo apt-add-repository -y ppa:nginx/development > /dev/null
	sudo apt-get -y update > /dev/null
	echo "... Installing nginx ..."
	sudo apt-get -y install nginx > /dev/null
fi

echo "... Configuring nginx ..."
# copy our modified nginx default site config to the vm
sudo cp /vagrant/configs/nginx-default /etc/nginx/sites-available/default

# restart nginx
sudo service nginx restart > /dev/null

echo "... End installing and configuring nginx."
echo " "
echo "================= FINISH STEP-4-INSTALL-NGINX.SH $(date +"%r") ================="
echo " "
