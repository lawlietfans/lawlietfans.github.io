---
layout: post
title: zabbix-quick-start
date: 2017-01-15 12:00:00
comments: true
external-url:
categories: [Linux, zabbix]
---

Zabbix is an enterprise-class open source distributed monitoring solution.[1]

Zabbix是一个企业级的、开源的、分布式的监控套件

- Zabbix可以监控网络和服务的监控状况. 
- Zabbix利用灵活的告警机制，允许用户对事件发送基于Email的告警. 这样可以保证快速的对问题作出相应. 
- Zabbix是零成本的. 因为Zabbix编写和发布基于GPL V2协议. 意味着源代码是免费发布的.

<!--more-->

Zabbix特性如下[2]：

1. 数据收集
1. 灵活的阀值定义
1. 高级告警配置
1. 实时绘图
1. 扩展的图形化显示
1. 历史数据存储
1. 配置简单
1. 模板使用
1. 网络自动发现
1. 快速的web接口
1. Zabbix API
1. 权限系统
1. 全特性、agent易扩展
1. 二进制守护进程
1. 具备应对复杂环境情况


可以总结为如下三个特点

1）灵活的通知机制：allows users to configure e-mail based alerts for virtually any event；

2）数据可视化；

3）所有报告、统计、参数配置都可通过web端完成；


所以zabbix很适合服务器集群管理员进行功能规划(capacity planning)

# 1 概览

- 架构
    - Server
    - database storage
    - web interface
    - proxy
    - agent
- 数据流(data flow)


![arch](http://images2015.cnblogs.com/blog/631533/201701/631533-20170115155021369-2100463231.png)

其中，Zabbix Server为中心组件，用来获取agent存活状况及监控数据和统计. 所有的配置、统计、操作数据均通过Server进行存取.

Zabbix agent部署在被监控机器上用来监控本地资源和应用（如硬盘、内存、处理器统计等）


# 2 术语概念

## 2.1 server / client / proxy

Zabbix server的功能可以分为三部分：server、web前端和database。

Server执行polling和trapping来采集数据，评估是否触发触发器，发送报警给用户

agent向其报告有效数据和统计。

database存储所有configuration, statistical and operational data。

server和web前端都与database进行交互。

Zabbix server以守护(daemon)进程方式运行

## 2.2 命令行工具

Sender / Get

# 3 zabbix进程构成 [3]

```c
默认情况下zabbix包含5个程序：
zabbix_agentd、zabbix_get、zabbix_proxy、zabbix_sender、zabbix_server，另外一个zabbix_java_gateway是可选

zabbix_agentd
客户端守护进程，此进程收集客户端数据，例如cpu负载、内存、硬盘使用情况等

zabbix_get
zabbix工具，单独使用的命令，通常在server或者proxy端执行获取远程客户端信息的命令。
通常用户排错。例如在server端获取不到客户端的内存数据，我们可以使用zabbix_get获取客户端的内容的方式来做故障排查。

zabbix_sender
zabbix工具，用于发送数据给server或者proxy，通常用于耗时比较长的检查。
很多检查非常耗时间，导致zabbix超时。于是我们在脚本执行完毕之后，使用sender主动提交数据。

zabbix_server
zabbix服务端守护进程。
zabbix_agentd、zabbix_get、zabbix_sender、zabbix_proxy、zabbix_java_gateway的数据最终都是提交到server
备注：当然不是数据都是主动提交给zabbix_server,也有的是server主动去取数据。

zabbix_proxy
zabbix代理守护进程。功能类似server，
唯一不同的是它只是一个中转站，它需要把收集到的数据提交/被提交到server里。

zabbix_java_gateway
zabbix2.0之后引入的一个功能。顾名思义：Java网关，类似agentd，但是只用于Java方面。
需要特别注意的是，它只能主动去获取数据，而不能被动获取数据。它的数据最终会给到server或者proxy。
```


# 4 安装zabbix

首先安装MariaDB数据库。Linux发行版，使用[repository configuration tool](https://downloads.mariadb.org/mariadb/repositories/)，选择自己合适的安装步骤。

- 卸载mysql

如果已经安装了mysql，需要先卸载mysql，否则安装过程中会出现冲突。

- 本机选择10.1stable for centos7 x86_64 

```sh
//添加源
shell> cat /etc/yum.repos.d/mariaDB.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1

shell> yum install MariaDB-server MariaDB-client mariadb

//服务管理，使用如下命令start/stop MariaDB:
shell> sudo systemctl start mariadb.service #直接用mariadb也行
shell> sudo systemctl stop mariadb.service
shell> sudo systemctl enable mariadb.service #开机自启动
```

从10.1起，Galera Cluster(同步MariaDB数据库的多master集群的工具)默认包含在MariaDB中。

see also [Installing MariaDB with yum](https://mariadb.com/kb/en/mariadb/yum/).

## 4.1 zabbix sever [4]

安装

```sh
shell> rpm -ivh http://repo.zabbix.com/zabbix/2.2/rhel/7/x86_64/zabbix-release-2.2-1.el7.noarch.rpm
//for Zabbix server and web frontend with mysql database
shell> yum install zabbix-server-mysql zabbix-web-mysql
//可以将server与agent安装在同一台机器
shell> yum install zabbix-agent
```

创建zabbix数据库以及远程用户

```c
[user@host ~]# mysql -uroot -p

MariaDB [(none)]> create database zabbix character set utf8 collate utf8_bin;
MariaDB [(none)]> grant all privileges on zabbix.* to zabbix@localhost identified by 'your_password';
MariaDB [(none)]> grant all privileges on zabbix.* to zabbix@'172.16.%.%' identified by 'your_password';
MariaDB [(none)]> flush privileges;
MariaDB [(none)]> select host,user from mysql.user;
+-----------------------+--------+
| host                  | user   |
+-----------------------+--------+
| 127.0.0.1             | root   |
| 172.16.%.%            | zabbix |
| ::1                   | root   |
| localhost             |        |
| localhost             | fsj    |
| localhost             | root   |
| localhost             | zabbix |
| localhost.localdomain |        |
+-----------------------+--------+
```

- 导入初始化schema和data

```sh
shell> cd /usr/share/doc/zabbix-server-mysql-2.2.15/create
shell> mysql -uroot -p  zabbix < schema.sql
shell> mysql -uroot -p  zabbix < images.sql
shell> mysql -uroot -p  zabbix < data.sql
```

- Edit database configuration in zabbix_server.conf

```sh
shell> vi /etc/zabbix/zabbix_server.conf
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=zabbix
```

- 开启zabbix-server服务：systemctl start zabbix-server

- Editing PHP configuration for Zabbix frontend
    - 修改timezone：`php_value date.timezone Asia/Shanghai`
    - 重启httpd服务：service httpd restart

或者通过sed调整php配置[6]

```sh
shell> sed -i 's/^.*date.timezone =.*$/date.timezone = Asia\/Shanghai/g' /etc/php.ini
shell> sed -i 's/^.*post_max_size =.*$/post_max_size = 16M/g' /etc/php.ini
shell> sed -i 's/^.*max_execution_time =.*$/max_execution_time = 300/g' /etc/php.ini
shell> sed -i 's/^.*max_input_time =.*$/max_input_time = 300/g' /etc/php.ini
shell> sed -i 's/^.* memory_limit =.*$/memory_limit = 128M/g'  /etc/php.ini
shell> service httpd restart
```

- 配置服务开机启动

```sh
shell> chkconfig zabbix-server on
shell> chkconfig zabbix-agent on
shell> chkconfig httpd on
```

访问 http://your-zabbix-server-ip/zabbix

默认username/password 是Admin/zabbix.

- 如果出现错误：zabbix server is not running

[解决办法](https://my.oschina.net/u/1590519/blog/330357)：设置SELinux 成为permissive模式  `shell> setenforce 0`

- 如果出现防火墙相关问题，打开agent的端口

```sh
查看zabbix监听端口：
shell> netstat -nlop | grep zabbix
tcp        0      0 0.0.0.0:10051           0.0.0.0:*               LISTEN      23904/zabbix_server  off (0.00/0/0)
tcp6       0      0 :::10051                :::*                    LISTEN      23904/zabbix_server  off (0.00/0/0)
打开防火墙该端口：
shell> iptables -I INPUT -p tcp --dport 10051 -m state --state NEW,ESTABLISHED -j ACCEPT
shell> iptables -I OUTPUT -p tcp --sport 10051 -m state --state ESTABLISHED -j ACCEPT
```

也可以批量修改其他端口：
```sh
shell> iptables-save > firewalls.txt
shell> vim firewalls.txt 
shell> iptables-restore <firewalls.txt 
```

或者直接关闭防火墙：`# systemctl stop firewalld`   

see also [Linux防火墙配置(iptables, firewalld)](http://www.cnblogs.com/pixy/p/5156739.html)


## 4.2 zabbix agent

```sh
shell> sudo rpm -ivh http://repo.zabbix.com/zabbix/2.2/rhel/7/x86_64/zabbix-release-2.2-1.el7.noarch.rpm
shell> sudo yum install zabbix-agent zabbix-sender -y
shell> grep -Ev '(^$|^#)' /etc/zabbix/zabbix_agentd.conf  #修改server地址
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=0
Server=172.16.44.5
Hostname=Zabbix server fsj
Include=/etc/zabbix/zabbix_agentd.d/

shell> sudo service zabbix-agent start
shell> sudo systemctl enable zabbix-agent
```

# 5 用户管理

![user list](http://ww1.sinaimg.cn/large/7156462egw1fb0n5yw928j218e0e0jzk.jpg)

![user groups list](http://ww1.sinaimg.cn/large/7156462egw1fb0njs2v9ij218g0cf7b0.jpg)

权限管理并不是直接设置一个user对应于一个host的什么权限，而是设置user groups对应与host groups的权限。

![](http://ww3.sinaimg.cn/large/7156462egw1fb0nmppfp0j20vy0futd2.jpg)

切换到permissions选项卡

![](http://ww4.sinaimg.cn/large/7156462egw1fb0nnyipqzj20zh0ohgq8.jpg)

# 6 开始监控

## 6.1 添加Zabbix agent（局域网其他机器）以及其item

新建host
![new host](https://www.zabbix.com/documentation/2.2/_media/manual/quickstart/new_host.png)

其中，最好有一个Host name项和`/etc/zabbix/zabbix_agentd.conf`中Hostname保持一致。

如果不存在host与配置文件中的Hostname相同，那么运行之后log文件会报错`host xxx(Hostname值) not found`，但是前端host条目依然可以获取到数据。

修改conf文件后要重启服务才能生效

新建item
![new item](https://www.zabbix.com/documentation/2.2/_media/manual/quickstart/new_item.png)

其中key表示要监测的的信息。
1. 详细：https://www.zabbix.com/documentation/2.2/manual/config/items/itemtypes/zabbix_agent
2. [Items supported by platform](https://www.zabbix.com/documentation/2.2/manual/appendix/items/supported_by_platform)

在configuration->hosts页面可看到刚刚添加的host，如果available项为绿色Z表示一切正常。

![host list](http://images2015.cnblogs.com/blog/631533/201701/631533-20170115155508338-57307903.png)

有可能出现如下错误
>Received empty response from Zabbix Agent at [x.x.x.x]. Assuming that agent dropped connection because of access permission

到Monitoring -> Latest data页面查看监控到的实时数据

![latest data](http://images2015.cnblogs.com/blog/631533/201701/631533-20170115155638994-755881875.png)

点击graph可以查看cpu load的折线图。

## 6.2 触发器

一个触发器包括一个定义了数据阈值的[表达式](https://www.zabbix.com/documentation/2.2/manual/config/triggers/expression)。

格式为`{<server>:<key>.<function>(<parameter>)}<operator><constant>`。  
其中：
1. key: 该server定义的item
2. function: https://www.zabbix.com/documentation/2.2/manual/appendix/triggers/functions
3. parameter: 数字n表示n秒，#n表示最近n个值，n[m|h|d]表示n[分钟|小时|天]

输入数据如果高于该阈值，触发器就会报警。

### 6.2.1 创建触发器

![new trigger](https://www.zabbix.com/documentation/2.2/_media/manual/quickstart/new_trigger.png)

激活触发器 `shell> cat /dev/urandom | md5sum`

![latest data graph of cpu load](http://ww4.sinaimg.cn/large/7156462egw1fazje03tolj217q0itgs1.jpg)

![monitoring-triggers](http://ww4.sinaimg.cn/large/7156462egw1fazjga5c24j218b0iegsq.jpg)

更多触发器示例：

1. `{www.zabbix.com:system.cpu.load[all,avg1].last()}>5`
2. `{www.zabbix.com:system.cpu.load[all,avg1].last()}>5|{www.zabbix.com:system.cpu.load[all,avg1].min(10m)}>2`
3. `{www.zabbix.com:vfs.file.cksum[/etc/passwd].diff()}=1`

### 6.2.2 通知

Administration -> Media type 设置 email（需要有email软件支持）

![](https://www.zabbix.com/documentation/2.2/_media/manual/quickstart/1.9.7_media_type_email.png)

新建action

![](http://images2015.cnblogs.com/blog/631533/201701/631533-20170115155906385-1184761700.png)


查看发送情况

![administration audit](http://images2015.cnblogs.com/blog/631533/201701/631533-20170115160022431-741622625.png)

这里没有设email相关，所以发送失败

# 7 使用模版

点击host，切换到templates选项卡可以关联想要的模版。

![](http://images2015.cnblogs.com/blog/631533/201701/631533-20170115160241322-10249453.png)

我们也可以通过 Configuration → Templates 可以创建空模版。然后把现有的item、trigger等拷贝到该模版，方便以后批量应用。
![](http://images2015.cnblogs.com/blog/631533/201701/631533-20170115160503838-460061465.png)



# References

1. https://www.zabbix.com/documentation/2.2/manual
2. http://zabbix-manual-in-chinese.readthedocs.io/en/latest/index.html
3. http://www.ttlsa.com/zabbix/zabbix-section-3-of-chapter-1/
4. https://www.zabbix.com/documentation/2.2/manual/quickstart
5. [跟着ttlsa一起学zabbix监控](http://www.ttlsa.com/zabbix/follow-ttlsa-to-study-zabbix/)
6. [监控 Zabbix](http://www.cnblogs.com/Brandyn/p/5443491.html)
7. http://zabbix.org.cn
