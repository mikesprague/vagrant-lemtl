#!/bin/bash

echo "================= START STEP-5-INSTALL-MYSQL.SH $(date +"%r") ================="
echo " "
echo "BEGIN Database server setup ..."

if [ ! -d "/etc/mysql" ]; then
	echo "... Setting MySQL root user password ..."
	sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $1"
	sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $1"

	echo "... Installing MySQL Server ..."
	# install mysql (-qq implies -y --force-yes)
	sudo apt-get install -qq mysql-server > /dev/null

	# make mysql available to connect to from outside world without ssh tunnel
	# copy file with above changes and the lower_case_table_names = 1 flag set to
	# ignore case sensitivity in the database
	sudo cp /vagrant/configs/mysql-my.cnf /etc/mysql/my.cnf

	sudo service mysql restart > /dev/null
fi

echo "... Setting up database and granting privileges ..."

if [ -f /vagrant/$2 ]; then
	echo "... SQL file found, importing data (this may take a few minutes) ..."
	# create database
	echo "CREATE DATABASE IF NOT EXISTS $3;" | mysql -uroot -p$1
	# import sql file
	echo "SOURCE /vagrant/$2;" | mysql -uroot -p$1 -f -D $3
fi

# create databases used for railo client and session storage
echo "... Creating databases for Railo's session and client storage ..."
echo "CREATE DATABASE IF NOT EXISTS railo_client;" | mysql -uroot -p$1
echo "CREATE DATABASE IF NOT EXISTS railo_session;" | mysql -uroot -p$1

# grant all privileges to mysql root user (from all hosts) on all databases
echo "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$1' WITH GRANT OPTION;" | mysql -uroot -p$1
echo "FLUSH PRIVILEGES;" | mysql -uroot -p$1

echo "... END Database server setup."
echo " "
echo "================= END STEP-5-INSTALL-MYSQL.SH $(date +"%r") ================="
