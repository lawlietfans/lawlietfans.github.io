---
layout: post
title: Oracle 11g 导入导出
date: 2017-09-28 12:00:00
comments: true
external-url:
categories: [database]
---

# 问题

环境：oracle 11g; redhat 6

usera是具有DBA权限，密码为usera

全量导出usera用户下的所有内容，并导入到新建的userb用户

# 解决

创建Directory: `create or replace directory DUMP_DIR_D as '/home/oracle/rhuser/oracledmp';`

1、重新测试之前要恢复环境

```sql
DROP USER userb cascade;
drop tablespace tbsfsj including contents and datafiles;
```

2、创建表空间和用户及赋权

```sql
create TABLESPACE tbsfsj DATAFILE '/home/oracle/rhuser/tbsfsj.dbf'  -- redhat user
size 10M autoextend on maxsize 30G;

create user userb identified by userb default tablespace tbsfsj;
-- grant connect, resource, DATAPUMP_IMP_FULL_DATABASE, DATAPUMP_EXP_FULL_DATABASE
-- to userb;
GRANT dba to userb;
grant read, write on directory DUMP_DIR_D to userb;
```

3、schemas方式导出

`expdp usera/usera directory=DUMP_DIR_D dumpfile=exp1.dmp logfile=exp1.log schemas=mop`

4、schemas方式导入

`impdp userb/userb schemas=mop directory=DUMP_DIR_D  dumpfile=imp1.dmp logfile=imp1.log  remap_schema=mop:userb`

### 核对

```sql
-- 以新用户userb登录，检查是否成功导入

SQL> select count(*) from user_tables;

  COUNT(*)
----------
       126

SQL> select count(*) from user_views;

  COUNT(*)
----------
   1

SQL> select count(*) from user_sequences;

  COUNT(*)
----------
  32

SQL> select count(*) from user_triggers;

  COUNT(*)
----------
   0
```

### 脚本

```sh
$ ssh root@remote_server_ip

$ su - oracle

$ cd /home/oracle/rhuser
```

```sh
$ cat exp1_schemas_mop.sh
#!/bin/bash
if [ "$1" = '' ]
then
    filename=defaultexp
else
    filename=$1
fi
dumppathprefix="/home/oracle/rhuser/oracledmp"

starttime=`date +'%s'`
expdp usera/usera directory=DUMP_DIR_D dumpfile=$filename.dmp logfile=$filename.log schemas=mop
endtime=`date +'%s'`

res="本次运行时间： "$((endtime-starttime))"s"
echo $res>>"$dumppathprefix/$filename.log"
echo $res
```

```sh
$ cat imp1_schemas_mop2fsj.sh
#!/bin/bash
if [ "$1" = '' ]
then
    filename=defaultimp
else
    filename=$1
fi
if [ "$2" = "" ]
then
    dmp=exp1_schemas
else
    dmp=$2
fi
dumppathprefix="/home/oracle/rhuser/oracledmp"

starttime=`date +'%s'`
impdp userb/userb schemas=mop directory=DUMP_DIR_D  dumpfile=$dmp.dmp logfile=$filename.log  remap_schema=mop:userb
endtime=`date +'%s'`

res="本次运行时间： "$((endtime-starttime))"s"
echo $res>>"$dumppathprefix/$filename.log"
echo $res
```


# 讨论

[What Is Data Pump Export?](https://docs.oracle.com/cd/E11882_01/server.112/e22490/dp_export.htm)

Data Pump Export (hereinafter referred to as Export for ease of reading) is a utility for unloading data and metadata into a set of operating system files called a dump file set. The dump file set can be imported only by the Data Pump Import utility. The dump file set can be imported on the same system or it can be moved to another system and loaded there.

The dump file set is made up of one or more disk files that contain table data, database object metadata, and control information. The files are written in a proprietary, binary format. During an import operation, the Data Pump Import utility uses these files to locate each database object in the dump file set.

Because the dump files are written by the server, rather than by the client, the database administrator (DBA) must create directory objects that define the server locations to which files are written. See "Default Locations for Dump, Log, and SQL Files" for more information about directory objects.

Data Pump Export enables you to specify that a job should move a subset of the data and metadata, as determined by the export mode. This is done using data filters and metadata filters, which are specified through Export parameters. See "Filtering During Export Operations".

To see some examples of the various ways in which you can use Data Pump Export, refer to "Examples of Using Data Pump Export".


Export provides different modes for unloading different portions of the database. The mode is specified on the command line, using the appropriate parameter. The available modes are described in the following sections:

- "Full Export Mode"
- "Schema Mode"
- "Table Mode"
- "Tablespace Mode"
- "Transportable Tablespace Mode"

The mode is specified on the command line, using the appropriate parameter. The available modes are described in the following sections:

- "Full Import Mode"
- "Schema Mode"
- "Table Mode"
- "Tablespace Mode"
- "Transportable Tablespace Mode"


# 参考

1. [Oracle简单常用的数据泵导出导入(expdp/impdp)命令举例(上)](http://www.cnblogs.com/jyzhao/p/4522868.html)
2. [Oracle简单常用的数据泵导出导入(expdp/impdp)命令举例(下)](http://www.cnblogs.com/jyzhao/p/4530575.html)
