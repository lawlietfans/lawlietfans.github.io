---
layout: post
title: 文本处理工具awk基础用法
date: 2017-12-16 12:00:00
comments: true
external-url:
categories: [wiki]
---


sed是以行为单位的文本处理工具，awk则以列为单位。

文件都是结构化的，都是有单词和空白字符组成的。

空白字符包括空格、tab以及连续的空格和tab。

- 每个非空白部分叫做域，获取指定的域：
  - `$0` 全部域
  - `$1` 第1个域
  - 。。。


默认以空白字符为分隔符，打印前两列
```sh
fsj@ubuntu:~/templates$ cat data.txt 
a.wang  Male  30  021-11111111
b.yang  Female  25  021-22222222
c.liu Male  33  021-33333333
d.gong  Female  24  021-44444444

fsj@ubuntu:~/templates$ awk '{print $1,$2}' data.txt 
a.wang Male
b.yang Female
c.liu Male
d.gong Female
```

`-F`指定其他分割符，打印前两列

```sh
fsj@ubuntu:~/templates$ awk -F. '{print $1,$2}' data.txt 
a wang  Male  30  021-11111111
b yang  Female  25  021-22222222
c liu Male  33  021-33333333
d gong  Female  24  021-44444444
```


内部变量NF表示每行有多少域
```sh
fsj@ubuntu:~/templates$ awk '{print NF}' data.txt 
4
4
4
4
```

同理，`{print $NF}`可以打印最后一个域，`{print $NF-1}`打印倒数第二域


截取字符串：substr(指定域, 子串开始位置, 子串结束位置)。不写子串结束位置表示到末尾

内部变量length表示当前行的长度

```sh
fsj@ubuntu:~/templates$ cat data.txt | awk '{print substr($1,3)}'
wang
yang
liu
gong
fsj@ubuntu:~/templates$ cat data.txt | awk '{print substr($1,3)}' | awk '{print $NF,length}'
wang 4
yang 4
liu 3
gong 4
```

求数字列之和，并打印

```sh
fsj@ubuntu:~/templates$ cat data.txt | awk 'BEGIN{total=0}{total+=$3} END {print total}'
112

# total/行数
fsj@ubuntu:~/templates$ cat data.txt | awk 'BEGIN{total=0}{total+=$3}END{print total/NR}'
28
```

输出行号
```sh
fsj@ubuntu:~/templates$ cat data1.txt
a wang  Male  30  021-11111111
b yang  Female  25  021-22222222
c liu Male  33  021-33333333

fsj@ubuntu:~/templates$ cat data1.txt | awk 'BEGIN{total=0}{total+=$3}END{print NF,NR}'
4 3

fsj@ubuntu:~/templates$ cat data1.txt | awk '{print NF,NR}'
4 1
4 2
4 3
```

## 实战问题 1

文本中有多行数据，每一行可能有keyword，找出包含keyword的连续两行行号

假设内容如下
```sh
fsj@ubuntu:~/tmp$ cat meitu.txt 
abc
66 kw
kw 4
d x
gdas
dsafd
ddd34
qq2

dtttt
kw3 kw kw
666666666666

kw
kw
theend
```

grep可以查到包含关键字kw的行
```sh
fsj@ubuntu:~/tmp$ grep kw meitu.txt -n
2:66 kw
3:kw 4
11:kw3 kw kw
14:kw
15:kw
```

如何查找连续两行行号？
同样要编写脚本ctrow.sh，判断上一个kw所在行和当前kw所在行是否相差1

```sh
#!/bin/bash
pre=-100 # 上一个行号
for i in `grep kw meitu.txt -n | awk -F: '{print $1}'`
do
  if [ $((pre+1)) -eq $i ]; 
  then
      echo $i
  fi
  pre=$i
done
```

运行下：
```sh
fsj@ubuntu:~/tmp$ sh ctrow.sh 
3
15
```


# References

1. 王军. Linux系统命令及Shell脚本实践指南
