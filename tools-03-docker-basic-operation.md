---
layout: post
title: docker基本操作
date: 2017-12-02 12:00:00
comments: true
external-url:
categories: [docker]
---

# 安装

```sh
$ sudo yum remove docker \ # 移除旧版本
                  docker-common \
                  docker-selinux \
                  docker-engine
$ curl -sSL https://get.daocloud.io/docker | sh # 超时

$ sudo yum -y install docker-io
$ sudo chkconfig docker on
$ sudo docker version
Client:
 Version:         1.12.6
 API version:     1.24
 Package version: docker-1.12.6-61.git85d7426.el7.centos.x86_64
 Go version:      go1.8.3
 Git commit:      85d7426/1.12.6
 Built:           Tue Oct 24 15:40:21 2017
 OS/Arch:         linux/amd64

Server:
 Version:         1.12.6
 API version:     1.24
 Package version: docker-1.12.6-61.git85d7426.el7.centos.x86_64
 Go version:      go1.8.3
 Git commit:      85d7426/1.12.6
 Built:           Tue Oct 24 15:40:21 2017
 OS/Arch:         linux/amd64
```

# docker加速器

https://cr.console.aliyun.com/?spm=5176.1972343.0.2.739d6968UdvRn2#/accelerator

```sh
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://xxx"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```


# 使用

```sh
docker pull hello-world # 下载
docker images # 查看
docker rmi image-id #删除
```

```c
docker run --name container-name -d image-name # 运行镜像为容器
docker ps # 容器列表
docker start/stop container-name/container-id
docker logs container-name/container-id # 查看容器日志
docker run -d -p 6378:6379 --name port-redis redis # 映射容器的6379端口到本机的6378端口
docker rm container-id
```


# push自己的镜像

```sh
$ sudo docker login --username=fengshenjie@foxmail.com registry.cn-hangzhou.aliyuncs.com

# 默认为版本号为latest
$ sudo docker tag [ImageId] registry.cn-hangzhou.aliyuncs.com/lawlietfans/my-oracle-xe-11g:[镜像版本号]
$ sudo docker push registry.cn-hangzhou.aliyuncs.com/lawlietfans/my-oracle-xe-11g:[镜像版本号]

$ sudo docker tag f794779ccdb9  registry.cn-hangzhou.aliyuncs.com/lawlietfans/my-oracle-xe-11g:v20171130
$ docker images
REPOSITORY                                                       TAG                 IMAGE ID            CREATED             SIZE
wnameless/oracle-xe-11g                                          latest              f794779ccdb9        7 weeks ago         2.23GB
registry.cn-hangzhou.aliyuncs.com/lawlietfans/my-oracle-xe-11g   v20171130           f794779ccdb9        7 weeks ago         2.23GB
$ sudo docker push registry.cn-hangzhou.aliyuncs.com/lawlietfans/my-oracle-xe-11g:v20171130
done
```

![eg](https://dn-coding-net-production-pp.qbox.me/caa74865-670e-457a-9e7c-7228502f77b5.png)


# References

1. https://docs.docker.com/engine/installation/linux/docker-ce/centos/
2. http://get.daocloud.io/#install-docker
