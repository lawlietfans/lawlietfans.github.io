---
layout: post
title: Linux服务器配置和管理：虚拟机安装CentOS6.7
date: 2016-02-29 12:00:00
comments: true
external-url:
categories:
tags: Linux服务器配置和管理
---

>原文地址：http://lawlietfans.coding.me/blog/2016/02/29/introduction-and-centos67-install/

相比于在PC端的流行的Windows，多数服务器使用的则是Linux系统。对于刚刚进入IT领域的“菜鸟”而言，学习和掌握Linux服务器配置与管理是非常有意义的。学windows，天天跟着时尚跑，今天DNA，明天COM，后天.NET; 而Unix/Linux，几十年前的思想今天看来依然光彩夺目。（[学习 Linux 有哪些好处？](http://www.zhihu.com/question/19771396))。

本系列教程全部都是基于vmware 11.1+ centos 6.7 i386的，宿主机为Windows7 x64操作系统。  
本文内容包括：发展史；自由软件文化；Linux系统的优势；安装使用。

CentOS是Community ENTerprise Operating System的简称，是Linux的一个发行版本。发行版其实就是一些整合的安装套件，它是由一些有系统整合能力的工作小组、机构或商业化公司等主动搜集并整合了网络上的部分Linux程序，把系统内核、附带的工具程序以及应用软件包等打包在一起，组成的一个Linux操作系统的集合体。安装者可以一次安装一个包括各种程序在内的完整系统，极大地提高了系统的安装效率。

其中RHEL(Red Hat Enterprise Linux)是很多企业采用的linux发行版本，需要向RedHat付费才可以使用，并能得到付过费用的服务和技术支持和版本升级。CentOS是RHEL的克隆版本，可以像REHL一样的构筑linux系统环境，但不需要向RedHat付任何的费用，同样也得不到任何有偿技术支持和升级服务。

# Linux发展史；自由软件文化；Linux系统的优势
对new beginner来说，这部分没什么意义，网上内容很多，你懂的。

# 0 安装前准备

- vmware虚拟机
- [centos6.7 iso文件](http://mirrors.163.com/centos/6.7/isos/i386/)
  - 只需要下载CentOS-6.7-i386-bin-DVD1.iso就可以了。
  - DVD1已经包含了完整的base distribution，不需要下载DVD2

# 1 安装流程
参考[1]即可，流程如下：

- 创建虚拟机vm-centos（我这里测试用机磁盘大小填的40GB）
- 设置centos，添加系统镜像文件
- 启动虚拟机，进入安装步骤

其中在在分区这一步，直接选择Use All Space比较简单，centos会默认分区。

![](http://www.linuxdown.net/uploads/allimg/150823/02055WV8-25.jpg)

我这里选择的自定义虚拟分区，划分`/boot`分区为300M，剩余的为LVM，具体如下：

```c
/boot  300M
/LVM  
  / 20G
  /var (余下全部)
  /swap(自己内存大小)
```

>这里为什么要用LVM？ LVM：逻辑卷管理，把硬盘、分区作为物理卷PV，建立卷组VG，VG上建逻辑卷LV，再做成文件系统、裸设备，优点是可扩展性强  
标准分区：就是硬盘分区，可以做裸设备，或建文件系统，受硬盘大小限制，可扩展性差

- 安装完成

# 2 更新系统
- 打开terminal，输入`sudo yum update`

>在linux系统中，普通用户可以通过sudo 命令以super user 身份执行指令，只要输入该用户的密码即可。

如果登陆系统后执行sudo 命令提示`该用户不存在与群组sudoers中`，那么你需要[把用户添加到sudo列表中](http://www.centoscn.com/CentOS/2015/0417/5200.html)

- 修改`/etc/sudoers`即可

```c
root  ALL=(ALL)   ALL    # 后面换行并将当前用户添加进去  
xxx   ALL=(ALL)   ALL;    # xxx改成你的用户名
```

# 3 设置开机自动联网

```c
[fsj@vm-centos ~]$ sudo vi /etc/sysconfig/network-scripts/ifcfg-eth0 

把ONBOOT="no"改为yes
```

>控制台上`[fsj@vm-centos ~]$`的通用格式为`[用户名@机器名称 当前路径]提示符`，其中提示符为$表示普通权限，后面以`$`开头的语句都是要在控制台输入的命令

# 4 安装OpenSSH Server
方便宿主机的xshell连接刚装好的虚拟机`vm-centos`

- $ yum search ssh
- $ yum install openssh-server
- 检查该服务开机启动：chkconfig --list sshd
- 手动启动sshd服务:`/etc/init.d/sshd start`

```c
$ chkconfig --list sshd
sshd            0:off 1:off 2:on  3:on  4:on  5:on  6:off
```
2~5都是on，就表明会自动启动

# 5 通过xshell连接`vm-centos`
安装好openssh之后就能在宿主机连接`vm-centos`了。

获取`vm-centos`地址

![](http://7xo0zf.com1.z0.glb.clouddn.com/16-3-18/64469253.jpg)
![](http://7xo0zf.com1.z0.glb.clouddn.com/16-3-18/84107400.jpg)

打开xshell，新建连接

![](http://7xo0zf.com1.z0.glb.clouddn.com/16-3-18/40913349.jpg)
![](http://7xo0zf.com1.z0.glb.clouddn.com/16-3-18/6379138.jpg)

连接成功

![](http://7xo0zf.com1.z0.glb.clouddn.com/16-3-18/93379079.jpg)

# ref
- [1] [虚拟机下安装CentOS 6.7系统教程](http://www.centoscn.com/image-text/setup/2015/0823/6047.html)
- [2] http://www.linuxidc.com/Linux/2011-07/39098.htm
- [3] [Linux 作为服务器操作系统的优势是什么？](http://www.zhihu.com/question/19738282)
