---
layout: post
title: spark单机环境搭建以及快速入门
date: 2018-09-02 12:00:00
comments: true
external-url:
categories: [x]
---

# 1 单机环境搭建

系统环境
```sh
cat /etc/centos-release
CentOS Linux release 7.3.1611 (Core)
```

**配置jdk8**
```sh
wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.tar.gz"
tar -xf jdk-8u181-linux-x64.tar.gz

echo 'export JAVA_HOME=/home/work/fsj/jdk1.8.0_181
export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc

source ~/.bashrc
java -version
```

**配置spark**

从http://spark.apache.org/downloads.html 下载最新版spark预编译包并解压。
```sh
echo 'export SPARK_HOME=/home/work/fsj/spark-2.3.0-bin-hadoop2.7
export PATH=$SPARK_HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
run-example SparkPi 10  # 运行例子
```

# 2 spark-shell

```sh
$ spark-shell --master local[2]
2018-09-02 16:12:37 WARN  NativeCodeLoader:62 - Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
Spark context Web UI available at http://localhost:4040
Spark context available as 'sc' (master = local[2], app id = local-1535875965532).
Spark session available as 'spark'.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.3.0
      /_/

Using Scala version 2.11.8 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_181)
Type in expressions to have them evaluated.
Type :help for more information.

scala> sc
res1: org.apache.spark.SparkContext = org.apache.spark.SparkContext@674aa626

scala> val textFile = spark.read.textFile("README.md")
2018-09-02 16:16:44 WARN  ObjectStore:6666 - Version information not found in metastore. hive.metastore.schema.verification is not enabled so recording the schema version 1.2.0
2018-09-02 16:16:45 WARN  ObjectStore:568 - Failed to get database default, returning NoSuchObjectException
2018-09-02 16:16:45 WARN  ObjectStore:568 - Failed to get database global_temp, returning NoSuchObjectException
textFile: org.apache.spark.sql.Dataset[String] = [value: string]

scala> textFile.first()
res2: String = # Apache Spark
```
可以看到shell给出了ui地址：http://localhost:4040

# 3 独立项目
spark-submit提交作业包括local模式和[集群模式](http://spark.apache.org/docs/latest/cluster-overview.html)。这里只涉及local模式。

通过maven来管理Scala依赖，新建SimpleApp项目。
代码和具体pom写法见：https://github.com/shenjiefeng/spark-examples/tree/master/SimpleApp

在pom文件中需要加上[scala maven plugin](https://docs.scala-lang.org/tutorials/scala-with-maven.html)，
由于插件包含scala，所以我们用maven编译项目时，本地并不需要配置scala

```sh
$ cd /path/to/SimpleApp && mvn clean package  # 建议选择国内mvn源
$ tree
.
├── pom.xml
├── src
│   └── main
│       └── scala
│           └── SimpleApp.scala
└── target
    ├── classes
    │   ├── SimpleApp$$anonfun$1.class
    │   ├── SimpleApp$$anonfun$2.class
    │   ├── SimpleApp.class
    │   └── SimpleApp$.class
    ├── classes.timestamp
    ├── maven-archiver
    │   └── pom.properties
    ├── simple-project-1.0.jar
    ├── surefire
    └── test-classes

$ spark-submit   --class "SimpleApp"   --master local[*]   target/simple-project-1.0.jar
...
```

修改spark-submit命令的日志级别：
```sh
$ cd $SPARK_HOME
$ cp conf/log4j.properties.template conf/log4j.properties
log4j.rootCategory=INFO, console # 改成WARN

$ spark-submit   --class "SimpleApp"   --master local[*]   target/simple-project-1.0.jar
18/09/02 17:27:52 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Lines with a: 61, Lines with b: 30
```

# 更多

- 集群环境搭建：https://showme.codes/2017-01-31/setup-spark-dev-env/
- http://spark.apache.org/docs/latest/quick-start.html
