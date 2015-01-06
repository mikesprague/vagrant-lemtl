# -*- mode: ruby -*-
# vi: set ft=ruby :

# server configuration
vm_ip_address = "192.168.50.25"
vm_naked_hostname = "vagrant-railo.dev"
vm_www_hostname = "www.vagrant-railo.dev"
vm_sql_hostname = "mysql.vagrant-railo.dev"
vm_timezone  = "US/Eastern"
vm_name = "Railo Tomcat MySQL Vagrant Box v1"
vm_max_memory = 1024
vm_num_cpus = 1
vm_max_host_cpu_cap = "50"

# database configuration
mysql_root_password = "password"
mysql_create_table_name = "cfartgallery"
mysql_file_to_import = "data/cfartgallery.sql"

# synced folder configuration
synced_webroot_local = "webroot/"
synced_webroot_box = "/sites/webroot"
synced_webroot_id = "vagrant-webroot"
synced_webroot_owner = "vagrant"
synced_webroot_group = "vagrant"

# bash script paths
bash_install_mysql = "bash-scripts/install-mysql.sh"
bash_install_tomcat = "bash-scripts/install-tomcat.sh"

Vagrant.configure("2") do |config|
	config.vm.box = "ubuntu/trusty64"
	# config.vm.box_url = "http://files.vagrantup.com/trusty64.box"
	config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
	config.vm.boot_timeout = 90

	config.vm.provider "virtualbox" do |v|
		# set name of vm
		v.name = vm_name
		# no matter how much cpu is used in vm, use no more than half of host machine's cpu
		v.customize ["modifyvm", :id, "--cpuexecutioncap", vm_max_host_cpu_cap]
		# set max amount of host machine ram allotted for vm to use
		v.memory = vm_max_memory
		# set number of cpus from host machine that vm is allowed to use
		v.cpus = vm_num_cpus
	end

	# set vm ip address
	config.vm.network :private_network, ip: vm_ip_address

	# set vm hostname
	config.vm.hostname = vm_naked_hostname
	config.hostsupdater.aliases = [
		vm_www_hostname, vm_sql_hostname
	]

	# install/configure mysql
	config.vm.provision :shell, :path => bash_install_mysql, :privileged => true, :args => [
		mysql_root_password, mysql_file_to_import, mysql_create_table_name, vm_timezone
	]

	# set vm timezone
	# install/configure tomcat
	# install/configure iptables
	# setup port forwarding to enable hostname/ip access without a port port number in the url
	config.vm.provision :shell, :path => bash_install_tomcat, :privileged => true, :args => [
		vm_name, vm_www_hostname, vm_ip_address, vm_sql_hostname
	]

	# forward vm port 80 to 8080
	config.vm.network :forwarded_port, :guest => 80, :host => 8080, :auto_correct => true

	# add synced folder
	config.vm.synced_folder synced_webroot_local, synced_webroot_box, :id => synced_webroot_id, :owner => synced_webroot_owner, :group => synced_webroot_group
end
