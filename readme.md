# Railo / Tomcat / MySQL Vagrant Box
## Last Updated January 06, 2015

--- 

### Prerequisites
#### Required
It is assumed you have Virtual Box and Vagrant installed. If not, then grab the latest version of each at the links below:
  1. [Virtual Box and Virtual Box Guest Additions](https://www.virtualbox.org/wiki/Downloads) (v4.3.20 at time of writing )
  2. [Vagrant](https://www.vagrantup.com/downloads.html) (v1.7.2 at time of writing)
  

#### Highly Recommended
Once Vagrant is installed, or if it already is, it's highly recommended that you install the following Vagrant plugins:
  1. vagrant-hostsupdater [ v0.0.11 at time of writing ]
  ```
  $ vagrant plugin install vagrant-hostsupdater
  ```
  2. vagrant-vbguest (v0.10.0 at time of writing)
  ```
  $ vagrant plugin install vagrant-vbguest
  ```

---
### What's Included
Note: All version numbers are as of the time of writing
* Ubuntu 14.04
* Tomcat 7.0.52
  * catalina.properties tweaks for improved performance
* Railo 4.2.2.004
  * MySQL and Postgres drivers updated to current versions (as of time of writing)
  * [cfspreadsheet](https://github.com/teamcfadvance/cfspreadsheet-railo) pre-installed
  * railo-inst.jar added to javaagent
  * Tweaks to Railo via server admin
    * Use J2EE sessions
    * Smart whitespace suppression and gzip compression enabled
    * Preserve single quotes option enabled for dataase queries
    * Update provider set to Development Releases
* MySQL 5.5.40
  * lower_case_table_names = 1 (disables case sensitivity)

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
==> default: Railo Tomcat MySQL Vagrant Box v1
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
==> default: MySQL Connection Info for External Connections (use localhost inside vm)
==> default:
==> default: Server: mysql.vagrant-railo.dev
==> default: Port: 3306
==> default: User: root
==> default: Password: password
==> default:
==> default: ===============================================================
```
Once you see that, you should be able to browse to [http://www.vagrant-railo.dev/](http://www.vagrant-railo.dev/)
or
[http://192.168.50.25/](http://192.168.50.25/)
(it may take a few minutes the first time a page loads after bringing your box up, subsequent requests should be much faster).

**NOTES**
  1. On Windows hosts machines, you should run your terminal as an Administrator and will also need to make sure your Hosts file isn't set to read-only if you want to take advantage of the hostname functionality. Or, simply use the IP address anywhere you would use the hostname (connecting to MySQL, etc).

---
#### TODO
  - Add optional Nginx install/configuration
  - Add MariaDB as an option for the database server
  
---
##### Project Inspiration
The following posts, written by [Mark Drew](http://www.markdrew.co.uk/blog/) in September, 2014, heavily influenced this project:
  - [Easy Railo App Development with Vagrant](http://blog.cmdbase.io/easy-railo-development-with-vagrant/)
  - [Saving Railo Configurations](http://blog.cmdbase.io/saving-railo-configurations/)

---

License
---
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
