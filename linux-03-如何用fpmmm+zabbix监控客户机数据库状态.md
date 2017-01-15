---
layout: post
title: using-fpmmm+zabbix-monitoring-database-state
date: 2017-01-15 13:00:00
comments: true
external-url:
categories: [fpmmm, MariaDB]
---

本文介绍如何通过fpmmm和zabbix来监控客户机上MariaDB数据库运行情况。

<!--more-->

首先在客户机安装MariaDB和zabbix，参考[上一篇](http://www.cnblogs.com/lawlietfans/p/6287192.html#安装zabbix)

安装fpmmm的过程主要参考[1]。

- 安装fpmmm的依赖

```sh
shell> yum install php-cli php-process php-mysqli
shell> cat << _EOF >/etc/php.d/fpmmm.ini
variables_order = "EGPCS"
date.timezone = 'Asia/Shanghai'
_EOF

shell> rpm -Uvh http://repo.zabbix.com/zabbix/2.2/rhel/7/x86_64/zabbix-release-2.2-1.el7.noarch.rpm
shell> yum update
shell> yum install zabbix-sender
```

- [下载](http://www.fromdual.com/download-performance-monitor)并安装fpmmm0.10.5

```sh
cd /opt
tar xf /tmp/fpmmm-0.10.5.tar.gz
ln -s fpmmm-0.10.5 fpmmm
```

- config

```sh
mkdir /etc/fpmmm
cp /opt/fpmmm/tpl/fpmmm.conf.template /etc/fpmmm/fpmmm.conf
chown -R zabbix: /etc/fpmmm
```

- vim `/etc/fpmmm/fpmmm.conf`

```cc
# This MUST match Hostname in Zabbix!
[machine01]
xxx

# Here you could add a random name of your MySQL/MariaDB instance
[mysqld01]          # This MUST match Hostname in Zabbix!
xxx
```

- create monitoring user(中创建监控的mysql的用户fpmmm)

```sh
MariaDB [(none)]> create user 'fpmmm'@'127.0.0.1' identified by 'your_password';
MariaDB [(none)]> grant process on *.* to 'fpmmm'@'127.0.0.1';
MariaDB [(none)]> grant replication client on *.* to 'fpmmm'@'127.0.0.1';
MariaDB [(none)]> grant select on mysql.user to 'fpmmm'@'127.0.0.1';
```


此时，最好增加replication slave权限

`GRANT REPLICATION SLAVE ON *.* TO 'user_fpmmm'@'127.0.0.1';`  

这一条官网没有，不过不加的话会在log里面提醒你需要，主要为了show slave hosts。[3]


-  Adding the zabbix user to the mysql group

`usermod -G mysql zabbix`

- test fpmmm.conf并查看log

```sh
$ /opt/fpmmm/bin/fpmmm --config=/etc/fpmmm/fpmmm.conf 
1
$ cat /tmp/fpmmm/fpmmm.log
24634:2016-12-06 16:07:35.296 - ERR :     Cannot read PID file /var/run/mysqld/mysqld.pid (rc=1476).
24634:2016-12-06 16:07:35.296 - ERR :     Either file does not exist or I have no read permissions.
24634:2016-12-06 16:07:35.296 - ERR :     Are you sure the process is running?
24634:2016-12-06 16:07:35.296 - ERR :     Adding the zabbix user to the mysql group might help...
24634:2016-12-06 16:07:35.296 - ERR :     Module FromDualMySQLprocess got an error (rc=1476).
24634:2016-12-06 16:07:35.414 - WARN:     Binary Log is disabled. Module 'master' does not make sense for host mysqld... (rc=1308).
24634:2016-12-06 16:07:35.443 - WARN:     Instance mysqld seems not to be a Slave. (rc=1577).
```

- 去除ERR
    - 修改pid路径: `PidFile = /var/lib/mysql/localhost.pid`
    - [打开bin log](http://www.cnblogs.com/xiaoheike/p/5873274.html)

```sh
shell> vim /etc/my.cnf
[client]
...

[mysqld]
...
log-bin=mysql-bin

MariaDB [(none)]> show variables like 'log_bin%';
+---------------------------------+--------------------------------+
| Variable_name                   | Value                          |
+---------------------------------+--------------------------------+
| log_bin                         | ON                             |
| log_bin_basename                | /var/lib/mysql/mysql-bin       |
| log_bin_index                   | /var/lib/mysql/mysql-bin.index |
| log_bin_trust_function_creators | OFF                            |
+---------------------------------+--------------------------------+
```

- 最后再次test fpmmm.conf

```sh
$ /opt/fpmmm/bin/fpmmm --config=/etc/fpmmm/fpmmm.conf 
1
$ cat /tmp/fpmmm/fpmmm.log

//如果有意外情况，试着以root身份运行该命令
$ sudo -u root /opt/fpmmm/bin/fpmmm --config=/etc/fpmmm/fpmmm.conf
```

- 运行

测试没问题后，修改zabbix的agent配置文件[2]

```sh
shell> vim /etc/zabbix/zabbix_agentd.conf
UserParameter=FromDual.MySQL.check,/opt/fpmmm/bin/fpmmm --config=/etc/fpmmm/fpmmm.conf
shell> systemctl restart zabbix-agent
```

- 把fpmmm自带的模版导入到zabbix中

tpl文件的具体作用[4]

Template_FromDual.MySQL.mpm.xml (监控mpm agent本身,这个必须导入)  
Template_FromDual.MySQL.server.xml (监控Linux系统跟数据库使用相关的附加项)  
Template_FromDual.MySQL.process.xml (监控各种Linux进程[比如:mysqld,ndbd])  
Template_FromDual.MySQL.mysql.xml (监控MySQL常用状态变量)  
Template_FromDual.MySQL.innodb.xml (监控InnoDB存储引擎状态变量)  
Template_FromDual.MySQL.myisam.xml (监控MyISAM存储引擎状态变量)  
Template_FromDual.MySQL.master.xml (监控MySQL主从复制的Master状态)  
Template_FromDual.MySQL.slave.xml (监控MySQL主从复制的Slave状态)  
  
MPM其它用途的模板:  
Template_FromDual.MySQL.ndb.xml (监控MySQL Cluster)  
Template_FromDual.MySQL.galera.xml (监控MySQL Galera Cluster)  
Template_FromDual.MySQL.pbxt.xml (监控PBXT存储引擎状态变量)  
Template_FromDual.MySQL.aria.xml (监控Aria存储引擎的状态变量)  
Template_FromDual.MySQL.drbd.xml (监控DRBD设备状态信息  


- 在zabbix管理界面创建两个host

其中一个监控机器(one for the machine): 导入fpmmm和server这两个模版

另一个监控数据库(and one for the database): 导入其他templates

注意Agent interface为当前agent的ip地址。

- 定时运行fpmmm agent

```sh
shell> echo "UserParameter=FromDual.MySQL.check,/opt/fpmmm/bin/fpmmm --config=/etc/fpmmm/fpmmm.conf" > /etc/zabbix/zabbix_agentd.d/fpmmm.conf
```

注意上面的命令不能实现定时运行，要用用crontab实现。
```sh
shell> vim /etc/crontab
* * * * * root echo "" >> /tmp/fpmmm/fpmmm.log & /opt/fpmmm/bin/fpmmm --config=/etc/fpmmm/fpmmm.conf >/dev/null
shell> tail /tmp/fpmmm/fpmmm.log

67721:2016-12-14 15:39:01.293 - INFO: FromDual Performance Monitor for MySQL and MariaDB (fpmmm) (0.10.5) run started.
67721:2016-12-14 15:39:02.587 - INFO: FromDual Performance Monitor for MySQL and MariaDB (fpmmm) run finished (rc=0).

68008:2016-12-14 15:40:01.650 - INFO: FromDual Performance Monitor for MySQL and MariaDB (fpmmm) (0.10.5) run started.
68008:2016-12-14 15:40:02.944 - INFO: FromDual Performance Monitor for MySQL and MariaDB (fpmmm) run finished (rc=0).
```


- 不使用fpmmm如何监控数据库运行状态？

see also [使用zabbix2.2自带的mysql template，设置并查看mysql监控情况](http://www.yuminstall.com/zabbix-monitoring-mysql.html)



# References

1. [FPMMM INSTALLATION GUIDE](http://www.fromdual.com/fpmmm-installation-guide)
2. [Zabbix配合fpmmm(mpm)实现对Mysql的全面监控](http://ixhao.blog.51cto.com/11988319/1847221)
3. http://www.cnblogs.com/zejin2008/p/5416441.html
4. [Zabbix+Mysql Fpmmm（MPM）监控](http://www.linuxea.com/1304.html)
