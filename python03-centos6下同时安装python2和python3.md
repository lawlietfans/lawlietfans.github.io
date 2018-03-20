---
layout: post
title: centos6下同时安装python2和python3
date: 2018-03-20 12:00:00
comments: true
external-url:
categories: [python]
---

# 依赖项

```sh
#build-essential compile packages
yum groupinstall "Development Tools"

yum install openssl-devel
yum install zlib-devel
yum install make gcc gcc-c++ kernel-devel
```
>http://unix.stackexchange.com/questions/291737/zipimport-zipimporterror-cant-decompress-data-zlib-not-available

# 安装

```sh
wget https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tar.xz
cd Python-3.*
sudo ./configure
sudo make
sudo make install
```
注意make install完成后不应该出现Ignoring ensurepip failure: pip 8.1.1 requires SSL/TLS之类提示，出现Successfully installed pip-xxx才正确。

默认安装路径是/usr/local，可以通过prefix选项自定义，比如`./configure --prefix=/opt/python3`
>http://stackoverflow.com/questions/8087184/problems-installing-python3-on-rhel


软链接和alias

```sh
$ sudo ln -s /usr/local/bin/python3 /usr/bin/python3
$ alias python=/usr/bin/python3
```

一般python3目录下已经装好pip3了，如果没有，手动安装pip

```sh
$ wget https://bootstrap.pypa.io/get-pip.py
$ sudo python3 get-pip.py 
Collecting pip
  Downloading pip-9.0.1-py2.py3-none-any.whl (1.3MB)
    100% |████████████████████████████████| 1.3MB 8.7kB/s 
Collecting wheel
  Using cached wheel-0.29.0-py2.py3-none-any.whl
Installing collected packages: pip, wheel
  Found existing installation: pip 8.1.1
    Uninstalling pip-8.1.1:
      Successfully uninstalled pip-8.1.1
Successfully installed pip-9.0.1 wheel-0.29.0

$ ln -s /usr/local/bin/pip3 pip3
$ alias pip=/usr/bin/pip3
$ pip --version
pip 9.0.1 from /usr/local/lib/python3.5/site-packages (python 3.5)
```
