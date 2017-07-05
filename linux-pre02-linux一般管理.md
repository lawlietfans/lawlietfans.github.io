---
layout: post
title: Linux服务器配置和管理：一般管理
date: 2016-03-07 12:00:00
comments: true
external-url:
categories: [Linux]
---

```c
OUTLINE
- Step by step
- 如何编辑文件？——vim编辑器入门
- 用户管理
- 文件/目录权限管理
- ref
```

>原文地址：http://lawlietfans.coding.me/blog/2016/03/07/linux-foundation/

[上一篇](http://lawlietfans.coding.me/blog/2016/02/29/introduction-and-centos67-install/)提到，Linux发行版就是把系统内核、附带的工具程序以及应用软件包等打包在一起，组成的一个集合体或者套件。而CentOS是其中一种发行版。
这是Linux操作系统的结构。

![](http://7xo0zf.com1.z0.glb.clouddn.com/16-3-26/78979443.jpg)

其结构可以用kernel、shell和utility三个不同层次的同心圆来表示。其中kernel控制着系统运行的各个方面，影响着一个系统的整体性能
我们平时在Linux的使用中也大多是和shell、工具（utility）打交道。有了这些工具，程序员在shell命令行下几乎可以完成所有想做的工作，也正因为如此，Linux比Windows更加适合远程管理，因为后者的远程操作一般在GUI下完成，这无疑影响了服务器端的性能。


Linux下的工具是非常丰富的，任何一个程序员都可以共享自己做的小工具。如果我们想要掌握这些工具的使用。最好是系统看书比如《鸟哥的私房菜》。不想看书的话，搜到的有些资料内容比较零散，有的可能像百科一样，太过于全面[1]。这里试图从初学者用的角度来了解、演示一些常用管理工具。

<!-- more -->

# Step by step

- 1 xshell连上CentOS之后，如何关机重启呢？如何安装新软件？
  - `$ sudo shutdown -h` 或`halt` 
  - 重启系统：`$ sudo reboot`
  - 安装git: `$ sudo yum install git`

- 2 查看当前目录的信息

ls（list）命令可用来显示目录的内容。配合参 数的使用，能以不同的方式显示目录内容。[4]   
格式：ls [参数]  [目录名或文件名]
```c
[fsj@vm-centos shit]$ ls
a  b  c  d  shit.c
[fsj@vm-centos shit]$ ll
total 0
-rw-rw-r--. 1 fsj fsj 0 Mar 27 14:07 a
-rw-rw-r--. 1 fsj fsj 0 Mar 27 14:07 b
-rw-rw-r--. 1 fsj fsj 0 Mar 27 14:07 c
-rw-rw-r--. 1 fsj fsj 0 Mar 27 14:07 d
-rwxr--r--. 1 fsj fsj 0 Mar 27 13:10 shit.c
[fsj@vm-centos shit]$ ll -a
total 8
drwxr-x--x. 2 fsj fsj 4096 Mar 27 14:24 .
drwxr-xr-x. 3 fsj fsj 4096 Mar 17 22:06 ..
-rw-rw-r--. 1 fsj fsj    0 Mar 27 14:07 a
-rw-rw-r--. 1 fsj fsj    0 Mar 27 14:07 b
-rw-rw-r--. 1 fsj fsj    0 Mar 27 14:07 c
-rw-rw-r--. 1 fsj fsj    0 Mar 27 14:07 d
-rw-rw-r--. 1 fsj fsj    0 Mar 27 14:24 .hiden
-rwxr--r--. 1 fsj fsj    0 Mar 27 13:10 shit.c
```
其中`ll`等价于`ls -l`.

查看当前路径
```c
[fsj@vm-centos shit]$ pwd
/home/fsj/temp/shit
```

- 3 如何对文件和目录进行操作呢？  
  - file fileName： 显示指定file的信息
  - touch fileName：更新指定文件的时间，或新建空文件
  - cp path1 path2：将path1的文件复制到path2
  - rm fileName：删除指定文件
  - mv：移动指定文件（类似cp），或重命名文件
  - find：查找文件，如：find ./logs/ -name 'error*' 表示在logs目录下查找名称以error开头的文件

```c
[fsj@vm-centos shit]$ file a
a: ASCII text
[fsj@vm-centos shit]$ cp a a-bak
[fsj@vm-centos shit]$ ls
a  a-bak  b  c  d  shit.c
[fsj@vm-centos shit]$ mv a a-origin
[fsj@vm-centos shit]$ ls
a-bak  a-origin  b  c  d  shit.c
[fsj@vm-centos shit]$ find  a* 
a-bak
a-origin
[fsj@vm-centos shit]$ rm a-bak 
[fsj@vm-centos shit]$ ls
a-origin  b  c  d  shit.c
```


- 4 如何文本文件？
  - cat fileName：显示指定文件的全部内容
  - more：分页显示指定文件
  - less：分页显示指定文件
  - head：显示指定文件头部的信息
  - tail：显示指定文件尾部的信息

```c
[fsj@vm-centos shit]$ cat a-origin 
aaaaa
2

```  

- 5 命令使用技巧[2]

 在终端输入命令，按回车执行 
 - 命令可用tab键自动进行补齐 
 - 一般可使用-h、-help或--help参数查看命令 的说明以及该命令可用的参数 
 - 使用man(manual)命令也可查看其它命令的 说明以及其可用的参数     
  - 格式：man 其它命令 

```c
[fsj@vm-centos shit]$ man cat
```

 包括前面用到的几个命令在内，Linux命令可以分类如下：
 - 浏览目录命令:ls  pwd  cd 
 - 浏览文件命令:ls  cat  more  less  head  tail 
 - 目录操作命令:chmod  mkdir  rm  mv  cp  find 
 - 文件操作命令:chmod  vi  rm  mv  cp  ln  find  grep  tar  gzip 

# 如何编辑文件？——vim编辑器入门
vim编辑器是需要CentOS自带的vi编辑器的加强版，需要下载：`# yum install vim`.  
这里简单举两个栗子：
- 1 新建文件hello.txt，输入内容，保存并退出
  - `$ vim hello.txt`
  - 按i键进入编辑模式，输入三行内容
  - 按ESC键进入命令模式，输入`:wq`，保存并退出
- 2 编辑hello.txt，删除第一行，复制第二行到尾部

![](http://7xo0zf.com1.z0.glb.clouddn.com/16-3-27/72770552.jpg)

试着操作之后会对命令模式与插入模式有直观的了解。

# 用户管理

- 1 借助GUI新建用户`test0`

![](http://7xo0zf.com1.z0.glb.clouddn.com/16-3-27/28596222.jpg)  
查看该用户的home目录：
```c
[root@vm-centos home]# ll -a test0/
total 32
drwx------. 4 test0 test0 4096 Mar  6 19:44 .
drwxr-xr-x. 4 root  root  4096 Mar  6 19:44 ..
-rw-r--r--. 1 test0 test0   18 Jul 24  2015 .bash_logout
-rw-r--r--. 1 test0 test0  176 Jul 24  2015 .bash_profile
-rw-r--r--. 1 test0 test0  124 Jul 24  2015 .bashrc
-rw-r--r--. 1 test0 test0  500 Nov 27  2014 .emacs
drwxr-xr-x. 2 test0 test0 4096 Nov 12  2010 .gnome2
drwxr-xr-x. 4 test0 test0 4096 Mar  6 17:00 .mozilla
```

- 2 用`useradd`新建用户`test1`，并添加密码

```c
[root@vm-centos home]# useradd test1
[root@vm-centos home]# passwd test1
Changing password for user test1.
New password: 
BAD PASSWORD: it is WAY too short
BAD PASSWORD: is a palindrome
Retype new password: 
passwd: all authentication tokens updated successfully.
```

```c
[root@vm-centos home]# ll -a test1/
total 32
drwx------. 4 test1 test1 4096 Mar 27 11:41 .
drwxr-xr-x. 5 root  root  4096 Mar 27 11:41 ..
-rw-r--r--. 1 test1 test1   18 Jul 24  2015 .bash_logout
-rw-r--r--. 1 test1 test1  176 Jul 24  2015 .bash_profile
-rw-r--r--. 1 test1 test1  124 Jul 24  2015 .bashrc
-rw-r--r--. 1 test1 test1  500 Nov 27  2014 .emacs
drwxr-xr-x. 2 test1 test1 4096 Nov 12  2010 .gnome2
drwxr-xr-x. 4 test1 test1 4096 Mar  6 17:00 .mozilla
```

- 3 切换用户

test0-->test1-->root
```c
[test0@vm-centos home]$ su test1
Password: 
[test1@vm-centos home]$ 

[test1@vm-centos home]$ su
Password: 
[root@vm-centos home]#
```

- 4 删除用户

```c
[root@vm-centos home]# userdel test1
userdel: user test1 is currently used by process 3087
```

删除失败，接着参数`rf`，强制删除
```c
[root@vm-centos home]# userdel -rf test1
userdel: user test1 is currently used by process 3087
```

虽然依然提示test1正在被使用，但是删除成功了。其中r表示删除该用户的home文件夹，f表示强制删除。
```c
[root@vm-centos home]# userdel -h
Usage: userdel [options] LOGIN

Options:
  -f, --force                   force removal of files,
                                even if not owned by user
  -h, --help                    display this help message and exit
  -r, --remove                  remove home directory and mail spool
  -Z, --selinux-user            remove SELinux user from SELinux user mapping
```

- 拾遗

Linux下有三类用户，超级用户(root)具有操作系统的一切权限，UID值均为0。普通用户具有操作系统有限的权限，只能管理自己启动的进程，UID值500~6000。系统用户是为了方便系统管理，满足相应的系统进程对文件属主的的要求，系统用户不能登录，UID值1~499。

这里新建普通用户的UID会依次增长，fsj为500，test0为501，test1为502
```c
$ id fsj
uid=500(fsj) gid=500(fsj) groups=500(fsj)
$ id test0
uid=501(test0) gid=501(test0) groups=501(test0)
```

# 文件/目录权限管理

- 1 文件详情中有权限信息

```c
[fsj@vm-centos shit]$ ll
total 0
[fsj@vm-centos shit]$ touch shit.c
[fsj@vm-centos shit]$ ll
total 0
-rw-rw-r--. 1 fsj fsj 0 Mar 27 13:10 shit.c
```

其中第一列`-rw-rw-r--`表示当前文件权限，其他列see also：[4].  
这一列的第一个字符表示文件类型。取值包括：
```c
d ：目录 
- ：文件 
l ：链接 
s ：socket 
p ：named pipe 
b ：block device 
c  ：character device
```

剩下9位，3为一组。格式为：[属主权限][属组用户权限][其他用户权限]  

属主和属组用户为`rw-`，有读、写权限。  
其他用户为`r--`，有读权限。


- 2 用chmod设置文件权限

把前面shit.c权限改为只允许属主读写执行(rwx)，其他用户只能读(r).
```c
[fsj@vm-centos shit]$ chmod 744 shit.c 
[fsj@vm-centos shit]$ ll
total 0
-rwxr--r--. 1 fsj fsj 0 Mar 27 13:10 shit.c
```
744什么和rwx对应起来的呢？

我们用二进制来表示是否允许某个权限，允许就置1，不允许就置0，比如777表示所有用户都有读、写、执行权限。
7`7`7（8进制）=111`111`111（2进制），9位都置一，就是所有权限都开。  
这里7`4`4（8进制）=111`100`100（2进制），属主读写执行(rwx)，其他用户只能读(r).  

换算的时候rwx权重分别看作421那就简单了，比如`rw-`就是`110`，也是`6`.

修改权限有什么用呢？当你搞一些配置文件的时候会想起来的~

# ref

- [1] [linux工具快速教程](http://linuxtools-rst.readthedocs.org/zh_CN/latest/index.html)
- [2] Linux入门——郭桂鑫
- [3] [Linux中添加用户、删除用户时新手可能遇到的问题](http://www.2cto.com/os/201408/328936.html)
- [4] [ Linux "ls -l"文件列表权限详解](http://blog.csdn.net/jenminzhang/article/details/9816853)
