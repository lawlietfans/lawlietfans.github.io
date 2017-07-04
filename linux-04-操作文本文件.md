---
layout: post
title: Linux命令行操作文本文件
date: 2017-06-20 12:00:00
comments: true
external-url:
categories: [x, xx]
---


# 编辑: `paste/sort/uniq/cut/tr/split`

paste 将文件按照行合并，默认分隔符为tab。用-d指定分隔符。

```sh
root@ubuntu:/home/fsj/templates# cat 1.txt 
b
c
a
e
d
f
root@ubuntu:/home/fsj/templates# cat 2.txt 
3
2
4
5
1
11
root@ubuntu:/home/fsj/templates# paste 1.txt 2.txt 
b 3
c 2
a 4
e 5
d 1
f 11
root@ubuntu:/home/fsj/templates# paste -d : 1.txt 2.txt 
b:3
c:2
a:4
e:5
d:1
f:11
```

对无序数据排序 `sort [-ntkr] FILENAME`

  - n 数字排序
  - t 指定分隔符
  - k 指定第几列，和t配套。
  - r 反向排序

```sh
root@ubuntu:~/templates$ paste -d : 1.txt 2.txt >>12.txt
root@ubuntu:~/templates$ sort 12.txt 
a:4
b:3
c:2
d:1
e:5
f:11

# 把第二列按照字符串字典序排列
fsj@ubuntu:~/templates$ sort 12.txt -t : -k 2
d:1
f:11
c:2
b:3
a:4
e:5

# 把第二列按照数字排序
fsj@ubuntu:~/templates$ sort 12.txt -t : -k 2 -n
d:1
c:2
b:3
a:4
e:5
f:11
```

其中`>>`或者`>`表示输出重定向。

去除重复内容（只比较相邻行）：`uniq [-ic]`

  - i 忽略大小写
  - c 计算重复行

```sh
fsj@ubuntu:~/templates$ cat uniq.txt 
abc
123
abc
123
fsj@ubuntu:~/templates$ uniq uniq.txt 
abc
123
abc
123
fsj@ubuntu:~/templates$ uniq uniq.txt -c
      1 abc
      1 123
      1 abc
      1 123

fsj@ubuntu:~/templates$ sort uniq.txt | uniq 
123
abc
fsj@ubuntu:~/templates$ sort uniq.txt | uniq -c
      2 123
      2 abc
```

其中`|`为管道符号，管道是一个固定大小的缓冲区，大小为1页，即4k byte。。命令`cmd1 | cmd2`表示，cmd1的输出会作为cmd2的输入。


截取文本每一行的指定范围：`cut -f 指定的列 -d'分隔符'`

  - 如果不指定分隔符，可以用-c把每个字符看成一列

```sh
fsj@ubuntu:~/templates$ cat /etc/passwd | head -n 5
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync

# 写成cut -f 1 -d : 也行
fsj@ubuntu:~/templates$ cat /etc/passwd | head -n 5 | cut -f 1 -d':'
root
daemon
bin
sys
sync

# 1,3表示第1和3列。1-3表示第1到第3列
fsj@ubuntu:~/templates$ cat /etc/passwd | head -n 5 | cut -f1,6 -d :
root:/root
daemon:/usr/sbin
bin:/bin
sys:/dev
sync:/bin
fsj@ubuntu:~/templates$ cat /etc/passwd | head -n 5 | cut -f1-2,6-7 -d :
root:x:/root:/bin/bash
daemon:x:/usr/sbin:/usr/sbin/nologin
bin:x:/bin:/usr/sbin/nologin
sys:x:/dev:/usr/sbin/nologin
sync:x:/bin:/bin/sync

# 第2到第4列的字符
fsj@ubuntu:~/templates$ cat /etc/passwd | head -n 2 | cut -c2-4
oot
aem
```

>passwd文件存放在/etc目录下。这个文件存放着所有用户帐号的信息，包括用户名和密码，因此，它对系统来说是至关重要的。
>其格式如下：username:password:User ID:Group ID:comment:home directory:shell


文本转换：tr

```sh
# 小写转大写
fsj@ubuntu:~/templates$ cat /etc/passwd | head -n 2 | tr '[a-z]' '[A-Z]'
ROOT:X:0:0:ROOT:/ROOT:/BIN/BASH
DAEMON:X:1:1:DAEMON:/USR/SBIN:/USR/SBIN/NOLOGIN

# 删除指定字符
fsj@ubuntu:~/templates$ cat /etc/passwd | head -n 2 | tr -d ':'
rootx00root/root/bin/bash
daemonx11daemon/usr/sbin/usr/sbin/nologin
```

分割大文件：split

```sh
fsj@ubuntu:~/templates$ ll ping.txt -h
-rw-rw-r-- 1 fsj fsj 43K Sep 28 20:15 ping.txt

# 按照行分割，-l指定每个100行为一个文件。
fsj@ubuntu:~/templates$ split -l 100 ping.txt pingx
fsj@ubuntu:~/templates$ ls ping*
ping.txt  pingxab  pingxad  pingxaf
pingxaa   pingxac  pingxae  pingxag
```

# 查找想要的文件

`find PATH -name FILENEAME`

```sh
eg
$ find / -name passwd
$ find ../ -name hello*
```

`locate FILENAME`，locate依赖于一个数据库文件，更加快速

`which FILENAME` 从PATH定义的目录中查找可执行文件的绝对路径

`whereis FILENAME` 相比which，还可以查出其他文件类型


# 查找文本文件中的指定内容

grep： 按`行`分析信息，符合结果就输出。

grep KEYWORD FILENAME [-ivnc]

  - 不区分大小写 i
  - 统计包含匹配的行数 c
  - 反向匹配 v

```sh
# 有c的时候n不起作用
root@ubuntu:/home/fsj/templates# grep icmp b.txt -nc
671
# 不包含icmp的行数是5行
root@ubuntu:/home/fsj/templates# grep icmp b.txt -vc
5
# 输出这5行
root@ubuntu:/home/fsj/templates# grep icmp b.txt -vn
1:PING baidu.com (180.149.132.47) 56(84) bytes of data.
673:
674:--- baidu.com ping statistics ---
675:674 packets transmitted, 671 received, 0% packet loss, time 682215ms
676:rtt min/avg/max/mdev = 42.046/47.206/928.390/36.489 ms
```


也可以[使用grep查找指定目录下的关键字](http://edsionte.com/techblog/archives/3164)

grep KEYWORD FOLDER [-rwnl]，例子：

  - 递归参数：grep -R 'boot' /etc
  - 完全匹配关键字：grep -R -w 'boot' /etc
  - 加上行号：grep -R -w -n 'boot' /etc
  - 显示包含在那个文件中：grep -R -w -l 'boot' /etc


# References

1. 王军 [Linux系统命令及Shell脚本实践指南](https://book.douban.com/subject/25803528/)
