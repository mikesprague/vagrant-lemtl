#!/bin/bash

# some final housekeeping
sudo apt-get -y autoremove > /dev/null

echo " "
echo "$1"
echo " "
echo "========================================================================"
echo " "
echo "http://$2 ($3)"
echo " "
echo "Lucee Server/Web Context Administrators"
echo " "
echo "http://$2/lucee/admin/server.cfm"
echo "http://$2/lucee/admin/web.cfm"
echo "Password (for each admin): password"
echo " "
echo " "
echo "Database Server Connection Info for External Connections "
echo "from Host Machine"
echo " "
echo "Server: $4"
echo "Port: 3306"
echo "User: root"
echo "Password: password"
echo " "
echo "========================================================================"
