# 1 假设有一个log文件，每行包含http返回码，shell找到返回码200的个数。

首先考虑每行最多出现一个200的情况

```sh
$ cat http.txt 
return 100
return 100
return 200
return 100
return 100
return 100
return 100	200	200
return 100 300 400

# 直接用grep就可以查出来
$ grep 200 http.txt -c #统计行数即可
2
```

如果每行可能多个200呢？

```sh
$ grep '\<200\>' http.txt
return 200
return 100	200	200
```

grep无能为力了，我们应该编写shell脚本计算

```sh
$ cat ct200.sh 
#!/bin/bash
count=0
for i in `cat http.txt` # for是以 任何空白字符 作为分隔符
do
	# 也可写成 "$i" = "200"
		if [ $i = 200 ];then
				let count+=1
		fi
done
echo $count
```

运行如下

```sh
$ bash ct200.sh
3
```




# 2 linux，文本中有多行数据，每一行可能有keywords，找出包含keywords的连续两行行号

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
pre=-2
ans=""
for i in `grep kw meitu.txt -n | awk -F: '{print $1}'`
do
	if [ $((pre+1)) -eq $i ]; then
			echo $i
	fi
	pre=$i
done
```

运行下：
```sh
fsj@ubuntu:~/tmp$ bash ctrow.sh 
3
15
```

# References

- 王军. linux系统命令及shell脚本实践指南
