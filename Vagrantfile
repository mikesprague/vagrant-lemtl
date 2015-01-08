# -*- mode: ruby -*-
# vi: set ft=ruby :

# server configuration
vm_ip_address = "192.168.50.25"
vm_naked_hostname = "vagrant-railo.dev"
vm_www_hostname = "www.vagrant-railo.dev"
vm_sql_hostname = "db.vagrant-railo.dev"
vm_timezone  = "US/Eastern"
vm_current_version = "v1.1.0"
vm_name = "Railo_Tomcat_Vagrant_MariaDB_MySQL_Box_#{vm_current_version}"
vm_max_memory = 1024
vm_num_cpus = 1
vm_max_host_cpu_cap = "40"

# database configuration
db_server_type = "mariadb" # valid options: "mysql" or "mariadb"
db_mariadb_version = "10.0"
db_root_password = "password"
db_create_database_name = "cfartgallery"
db_sql_file_to_import = "data/cfartgallery.sql"

# synced folder configuration
synced_webroot_local = "webroot/"
synced_webroot_box = "/sites/webroot"
synced_webroot_id = "vagrant-webroot"
synced_webroot_owner = "vagrant"
synced_webroot_group = "vagrant"


Vagrant.configure("2") do |config|
	config.vm.box = "ubuntu/trusty64"
	# config.vm.box_url = "http://files.vagrantup.com/trusty64.box"
	config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
	config.vm.boot_timeout = 90

	config.vm.provider "virtualbox" do |v|
		# set name of vm
		v.name = vm_name
		# no matter how much cpu is used in vm, use no more than vm_max_host_cpu_cap amount
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

	# set vm timezone and do some cleanup before installations
	config.vm.provision :shell, :path => "bash-scripts/step-1-set-vm-timezone.sh", :privileged => true, :args => vm_timezone

	# install miscellaneous utilities
	config.vm.provision :shell, :path => "bash-scripts/step-2-install-utilities.sh", :privileged => true

	# install/configure tomcat and iptables port forwarding (enable hostname/ip access without a port port number in the url)
	config.vm.provision :shell, :path => "bash-scripts/step-3-install-tomcat.sh", :privileged => true, :args => [
		vm_name, vm_www_hostname, vm_ip_address, vm_sql_hostname
	]

	# install/configure nginx
	# config.vm.provision :shell, :path => "bash-scripts/step-4-install-nginx.sh", :privileged => true, :args => [
	# 	vm_name, vm_www_hostname, vm_ip_address, vm_sql_hostname
	# ]

	# install/configure database server
	config.vm.provision :shell, :path => "bash-scripts/step-5-install-#{db_server_type}.sh", :privileged => true, :args => [
		db_root_password, db_sql_file_to_import, db_create_database_name, db_mariadb_version
	]

	config.vm.provision :shell, :path => "bash-scripts/step-6-final-output.sh", :privileged => true, :args => [
		vm_name, vm_www_hostname, vm_ip_address, vm_sql_hostname
	]

	# forward vm port 80 to 8080
	config.vm.network :forwarded_port, :guest => 80, :host => 8080, :auto_correct => true

	# add synced folder
	config.vm.synced_folder synced_webroot_local, synced_webroot_box, :id => synced_webroot_id, :owner => synced_webroot_owner, :group => synced_webroot_group
end
