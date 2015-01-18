#!/bin/bash

echo "BEGIN Set VM timezone and perform some cleanup pre-install ..."

# set server timezone
echo $1 | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata

# a little housekeeping
echo "... Doing a little housekeeping ..."
sudo apt-get -y autoremove > /dev/null
sudo apt-get -y update --fix-missing > /dev/null

echo "... END Set VM timezone and perform some cleanup pre-install."
echo " "
