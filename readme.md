# Railo / Tomcat / MySQL Vagrant Box
##### Last Updated January 08, 2015
---

### Prerequisites
NOTE: All version numbers used below are confirmed to work and are current as of the time of this writing

#### Required
It is assumed you have Virtual Box and Vagrant installed. If not, then grab the latest version of each at the links below:
* [Virtual Box and Virtual Box Guest Additions](https://www.virtualbox.org/wiki/Downloads) (v4.3.20)
* [Vagrant](https://www.vagrantup.com/downloads.html) (v1.7.2)

#### Highly Recommended
Once Vagrant is installed, or if it already is, it's highly recommended that you install the following Vagrant plugins:
* [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) (v0.0.11).
```$ vagrant plugin install vagrant-hostsupdater```
* [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) (v0.10.0).
```$ vagrant plugin install vagrant-vbguest```

---

### What's Included
* Ubuntu 14.04
	* Makes sure curl, wget, unzip, zip, iptables, debconf-utils, and software-properties-common are installed
	* Set's vm timezone (configure in Vagrantfile)
* Tomcat 7.0.52
	* catalina.properties tweaks for improved performance
	* Set up iptables port forwarding so vm can be accessed by hostname or ip address directly (without port number)
* Railo 4.2.2.004
	* MySQL and Postgres drivers updated to current versions (as of time of writing)
	* [cfspreadsheet](https://github.com/teamcfadvance/cfspreadsheet-railo) pre-installed
	* railo-inst.jar added to javaagent
	* Tweaks to Railo via server admin
		* Use J2EE sessions
		* Smart whitespace suppression and gzip compression enabled
		* Preserve single quotes option enabled for dataase queries
		* Update provider set to Development Releases
* MariaDB 10.0.15 or MySQL 5.5.40 (defaults to MariaDB, configure in Vagrantfile)
	* lower_case_table_names = 1 (disables case sensitivity)
	* bind-address set to 0.0.0.0 so MariaDB/MySQL can be accessed from the host machine directly (without ssh tunnel)
---

### Installation
The first time you clone the repo and bring the box up, it may take several minutes. If it doesn't explicitly fail/quit, then it is still working.
```
$ git clone https://github.com/mikesprague/vagrant-railo-tomcat-mysql.git
$ cd vagrant-railo-tomcat-mysql
$ vagrant up
```

Once the Vagrant box finishes and is ready, you should see something like this in your terminal:
```
==> default: Railo Tomcat MariaDB/MySQL Vagrant Box
==> default:
==> default: ===============================================================
==> default:
==> default: http://www.vagrant-railo.dev (192.168.50.25)
==> default:
==> default: Railo Server/Web Context Administrators
==> default:
==> default: http://www.vagrant-railo.dev/railo-context/admin/server.cfm
==> default: http://www.vagrant-railo.dev/railo-context/admin/web.cfm
==> default: Password (for each admin): password
==> default:
==> default:
==> default: Database Server Connection Info for External Connections
==> default: from Host Machine
==> default:
==> default: Server: db.vagrant-railo.dev
==> default: Port: 3306
==> default: User: root
==> default: Password: password
==> default:
==> default: ===============================================================
```
Once you see that, you should be able to browse to [http://www.vagrant-railo.dev/](http://www.vagrant-railo.dev/)
or [http://192.168.50.25/](http://192.168.50.25/)
(it may take a few minutes the first time a page loads after bringing your box up, subsequent requests should be much faster).

**NOTE**
* On Windows (host machines) you should run your terminal as an Administrator; you will also need to make sure your Hosts file isn't set to read-only if you want to take advantage of the hostname functionality. Alternatively, simply use the IP address anywhere you would use the hostname (connecting to database server, etc).

---
#### Planned Features
* [ ] Add optional Nginx install/configuration
* [x] Add MariaDB as an option for the database server
---

##### Project Inspiration
The following posts, written by [Mark Drew](http://www.markdrew.co.uk/blog/) in September, 2014, heavily influenced this project:
	- [Easy Railo App Development with Vagrant](http://blog.cmdbase.io/easy-railo-development-with-vagrant/)
	- [Saving Railo Configurations](http://blog.cmdbase.io/saving-railo-configurations/)
---

## License
```
The MIT License (MIT)

Copyright (c) 2015 Mike Sprague

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
