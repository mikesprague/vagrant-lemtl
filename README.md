# Vagrant LEMTL
Vagrant box with Linux, Nginx, MariaDB (or MySQL), Tomcat, and Lucee for local development with CFML and Java

##### Last Updated July 18, 2015
---

### Prerequisites
NOTE: All version numbers used in this document are confirmed to work, and are current, as of the above last updated date

#### Required
It is assumed you have Virtual Box and Vagrant installed. If not, then grab the latest version of each at the links below:
* [Virtual Box and Virtual Box Extension Pack](https://www.virtualbox.org/wiki/Downloads) (5.0)
* [Vagrant](https://www.vagrantup.com/downloads.html) (v1.7.4)
* **IMPORTANT NOTE:** If you're on Windows (not sure about other OSs) and you are running Virtual Box 5.0 (or want to) then you **MUST** install Vagrant v1.7.4; there are known bugs/issues with Vagrant v1.7.3 and below when used with Virtual Box 5.0. If you choose to stick with a 4.x version of Virtual Box I recommend using [v4.3.30](https://www.virtualbox.org/wiki/Download_Old_Builds_4_3) (plus matching [extension pack](http://download.virtualbox.org/virtualbox/4.3.30/Oracle_VM_VirtualBox_Extension_Pack-4.3.30-101610.vbox-extpack)) with [Vagrant v1.7.2](https://www.vagrantup.com/download-archive/v1.7.2.html)

#### Highly Recommended
Once Vagrant is installed, or if it already is, it's highly recommended that you install the following Vagrant plugins:
* [vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater) (v0.0.11).
```$ vagrant plugin install vagrant-hostsupdater```
* [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest) (v0.10.0).
```$ vagrant plugin install vagrant-vbguest```
* [vagrant-winnfsd](https://github.com/GM-Alex/vagrant-winnfsd) (v1.0.11).
```$ vagrant plugin install vagrant-winnfsd```
(*For Windows host machines that want to use NFS*)

---

### What's Included
* Ubuntu Server 14.04 (Trusty Tahr) 64bit
	* Make sure curl, wget, unzip, zip, iptables, debconf-utils, and software-properties-common are installed
	* Set vm timezone (configure in Vagrantfile)
	* NOTE: Tested and working with Ubuntu 12.04, 14.04, 14.10, 15.04 (configurable via Vagrantfile)
* Nginx 1.9.2
	* Set up to serve all static content and reverse-proxy cfm/cfc/jsp requests to Tomcat
* MariaDB 10.0.x or MySQL 5.5.x (defaults to MariaDB, configurable in Vagrantfile)
	* lower_case_table_names = 1 (disables case sensitivity)
	* bind-address set to 0.0.0.0 so database server can be accessed from the host machine directly (without ssh tunnel)
* Tomcat 7.0.52 with Java 1.7.0_79
	* catalina.properties tweaks for improved performance
* Lucee 4.5.2.000
	* MySQL JDBC driver updated to: Connector/J 5.1.36
	* Postgres JDBC driver updated to: JDBC41 Postgresql Driver, Version 9.4-1201
	* [cfspreadsheet-lucee](https://github.com/Leftbower/cfspreadsheet-lucee) pre-installed
		* Many thanks to Andrew Kretzer for his work updating cfspreadsheet-railo for Lucee compatibility
		* Apache POI library updated to: 3.12-20150511
	* lucee-inst.jar added to javaagent
	* Tweaks to Lucee via server admin
		* Smart whitespace suppression
		* Preserve single quotes option enabled for dataase queries
		* Update provider set to Development Releases

---

### Installation
The first time you clone the repo and bring the box up, it may take several minutes. If it doesn't explicitly fail/quit, then it is still working (the Linux updates, on first run, can take a while).
```bash
$ git clone https://github.com/writecodedrinkcoffee/vagrant-lemtl.git
$ cd vagrant-lemtl/vagrantroot && vagrant up
```

Once the Vagrant box finishes and is ready, you should see something like this in your terminal:
```bash
==> default: Vagrant-LEMTL-v1.5.1
==> default:
==> default: ===============================================================
==> default:
==> default: http://www.vagrant-lemtl.local (192.168.50.25)
==> default:
==> default: Lucee Server/Web Context Administrators
==> default:
==> default: http://www.vagrant-lemtl.local/lucee/admin/server.cfm
==> default: http://www.vagrant-lemtl.local/lucee/admin/web.cfm
==> default: Password (for each admin): password
==> default:
==> default:
==> default: Database Server Connection Info for External Connections
==> default: from Host Machine
==> default:
==> default: Server: db.vagrant-lemtl.local
==> default: Port: 3306
==> default: User: root
==> default: Password: password
==> default:
==> default: ===============================================================
```
Once you see that, you should be able to browse to [http://www.vagrant-lemtl.local/](http://www.vagrant-lemtl.local/)
or [http://192.168.50.25/](http://192.168.50.25/)
(it may take a few minutes the first time a page loads after bringing your box up, subsequent requests should be much faster).

**NOTES**
* On Windows (host machines) you should run your terminal as an Administrator; you will also need to make sure your Hosts file isn't set to read-only if you want to take advantage of the hostname functionality. Alternatively, simply use the IP address anywhere you would use the hostname (connecting to database server, etc).
* [Git Large File Storage (Git LFS)](https://git-lfs.github.com/) enabled via the .gitattributes file for .jar and .lco files by default. This should not cause any issues if you do not have Git LFS installed/enabled. If you don't have Git LFS installed locally (or enabled on your GitHub account), it should just ignore the attributes. If there are any problems, please report them in the issue tracker.

---

#### References
The following two posts, written by [Mark Drew](http://www.markdrew.co.uk/blog/) in September, 2014, heavily influenced this project:
* [Easy Railo App Development with Vagrant](http://blog.cmdbase.io/easy-railo-development-with-vagrant/)
* [Saving Railo Configurations](http://blog.cmdbase.io/saving-railo-configurations/)


Help with Nginx config from the following blog post by [Yuri Vorontsov](http://www.silverink.nl/):
* [Separating static from dynamic traffic with Nginx and Railo](http://www.silverink.nl/splitting-static-dynamic-traffic-nginx-railo/)

---

## License
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
