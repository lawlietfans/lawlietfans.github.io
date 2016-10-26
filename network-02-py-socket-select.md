网络编程的基本组建是socket[1]，包括：服务端socket和客户端socket。其中客户端socket只是简单的连接、完成事务、断开连接，而服务端socket流程多一些。

一个小型服务器

v1-server
```py
#!/usr/bin/env python
# coding=utf-8
import socket

s=socket.socket()
host=socket.gethostname()
port=8889
s.bind((host,port))

s.listen(10)
while True:
	conn,addr=s.accept()
	print "got conn from ",addr
	conn.send("thx for conn")
	conn.close()
```

服务端的accept方法会阻塞直到客户端连上。

一个小型客户机

v1-client
```py
#!/usr/bin/env python
# coding=utf-8
import socket

s=socket.socket()
host=socket.gethostname()
port=8889

s.connect((host,port))
print s.recv(1024)

```

# 1 使用SocketServer框架的服务器

复杂一些的场景可以使用SocketServer模块。在其设计中，server每收到一个请求，就会实例化一个请求处理程序。

v2-SocketServer
```py
# 和v1-client对应
from SocketServer import TCPServer,StreamRequestHandler
class Handler(StreamRequestHandler):
    def handle(self):
        addr=self.request.getpeername()
        print 'got connectino from ',addr
        self.wfile.write('thx for you connecting')
        
server=TCPServer(('',8889),Handler)
server.serve_forever()

```

# 2 多个连接

上述两种方案server一次只能处理一个连接，

要想同时处理多个连接，有三种方法：

- forking
- threading
- asnchronous I/O

其中threading方式下，每个socket交给一个线程处理，不同的socket通信过程互不干扰。

![](http://img.blog.csdn.net/20140818224818116)

v3-forking.py
```py
from SocketServer import TCPServer,StreamRequestHandler, ForkingMixIn

class Server(ForkingMixIn, TCPServer):	pass

class Handler(StreamRequestHandler):
    def handle(self):
        addr=self.request.getpeername()
        print 'got connectino from ',addr
        self.wfile.write('thx for you connecting')
        
server=Server(('',8889),Handler)
server.serve_forever()

```

v3-threading.py
```py
from SocketServer import TCPServer,StreamRequestHandler, ThreadingMixIn

class Server(ThreadingMixIn,TCPServer):	pass

class Handler(StreamRequestHandler):
    def handle(self):
        addr=self.request.getpeername()
        print 'got connectino from ',addr
        self.wfile.write('thx for you connecting')
        
server=Server(('',8889),Handler)
server.serve_forever()
```

# 3 使用select的简单服务器

服务器：v4-select.py
```py
#!/usr/bin/env python
# coding=utf-8
import socket, select
s=socket.socket()
host=socket.gethostname()
port=8889
s.bind((host,port))

s.listen(5)
inputs=[s]
print 's',s
while	True:
	rs,ws,es=select.select(inputs,[],[]) # read write except result
	#rs,ws,es=select.select(inputs,[],[],0) 
	print 'inputs ',inputs
	for r in rs:
		print 'rs ',len(rs),rs
		if r is s:
			c, addr = s.accept()
			print 'Got connection from',addr
			c.send('connect to server successful')
			inputs.append(c)
			print 'r,c ',r,c
		else:
			try:
				data = r.recv(1024)
				disconnected = not data
			except:
				disconnected = True

			if disconnected:
				print r.getpeername(),'disconnected'
				inputs.remove(r)
			else:
				print data
```

客户端：v4-client.py

```py
#!/usr/bin/env python
# coding=utf-8
import socket

s=socket.socket()
host=socket.gethostname()
port=8889

s.connect((host,port))
print socket.gethostname()
s.send("hi, i am "+socket.gethostname())
print s.recv(1024)
```

运行：

启动server
```sh
$ python v4-select.py 
s <socket._socketobject object at 0xb74d9d84>
inputs  [<socket._socketobject object at 0xb74d9d84>]
rs  1 [<socket._socketobject object at 0xb74d9d84>]
Got connection from ('127.0.0.1', 44464)
r,c  <socket._socketobject object at 0xb74d9d84> <socket._socketobject object at 0xb74d9d4c>
inputs  [<socket._socketobject object at 0xb74d9d84>, <socket._socketobject object at 0xb74d9d4c>]
rs  1 [<socket._socketobject object at 0xb74d9d4c>]
hi, i am ubuntu
inputs  [<socket._socketobject object at 0xb74d9d84>, <socket._socketobject object at 0xb74d9d4c>]
rs  1 [<socket._socketobject object at 0xb74d9d4c>]
('127.0.0.1', 44464) disconnected
```

启动client
```sh
$ python v4-client.py 
ubuntu
connect to server successful
```

python中提供的`select.select(rlist, wlist, xlist[, timeout])`是Unix中`select()`系统调用的一个接口。[4]

rlist、wlist、xlist都是waitable对象序列，分别表示：输入、输出以及异常情况的序列。

'waitable objects’: either integers representing file descriptors or objects with a parameterless method named fileno() returning such an integer

```sh
rlist: wait until ready for reading
wlist: wait until ready for writing
xlist: wait for an “exceptional condition”
```

当不提供可选参数timeout的时候，select会阻塞，直到至少一个文件描述符为行动做好了准备，才会继续运行。

当给定timeout秒数，select阻塞时间不会超过timeout秒。如果超时仍然没有准备好的文件描述符就会返回空结果。

返回值是3个list组成的tuple，这3个list分别是3个输入list的子集。

当timeout为0，会给出一个连续的poll（不阻塞），设置为0后可以看到`while True`函数体疯狂循环。

[1]中有些话都是直接翻译文档的，看完跟不看一样，略坑。

从执行的输出可以看到：

server端的，inputs列表开始只包含socket对象4c

第一次循环中，select从inputs中找到准备好的子集：4c

4c调用accept成功之后生成了socket对象84，并且被inputs列表添加.

第二次循环中，select从inputs中找到准备好的子集：84

84接收消息

这只是一个最简单的演示，所以

## [2]中的一些概念和[1]不同，这令人困惑。

[1]认为：

同步的服务器解决方案：server一次只能连接处理一个client

要实现多个连接，可以借助forking分出多个进程，并行处理多个socket连接。缺点是浪费资源。

或者用threading分多个线程，每个线程处理一个socket连接。缺点是需要进程同步。

异步IO可以避免上述问题，基本机制是select模块的select函数。


对应的[2]中认为：

```sh
同步/异步主要针对C端，阻塞/非阻塞主要针对S端。
同步IO和异步IO的区别就在于：数据访问的时候进程是否阻塞！
阻塞IO和非阻塞IO的区别就在于：应用程序的调用是否立即返回！

Linux下的五种I/O模型
1)阻塞I/O（blocking I/O）
2)非阻塞I/O （nonblocking I/O）
3) I/O复用(select 和poll) （I/O multiplexing）
4)信号驱动I/O （signal driven I/O (SIGIO)）
5)异步I/O （asynchronous I/O (the POSIX aio_functions)）

前四种都是同步，只有最后一种才是异步IO。
```

概念混乱不清，挖坑待辨析。

# 4 使用poll的简单服务器

v4-poll.py
```py
#!/usr/bin/env python
# coding=utf-8
import socket, select
s=socket.socket()
host=socket.gethostname()
port=8889
s.bind((host,port))

fdmap={s.fileno():s}
s.listen(5)
# 得到poll对象
p=select.poll()
p.register(s)

while	True:
	events=p.poll()
	for fd,event in events:
		if fd==s.fileno():
			c,addr = s.accept()
			print 'got connection from ',addr
			p.register(c)
			fdmap[c.fileno()] = c
		elif event & select.POLLIN:
			data=fdmap[fd].recv(1024)
			if not data:
				print fdmap[fd].getpeername(),'disconnected'
				p.unregister(fd)
				del fdmap[fd]
			else:	print data
```

## 4.1 select和poll的异同

[4]中提到：

>The poll() system call, supported on most Unix systems, provides better scalability for network servers that service many, many clients at the same time. poll() scales better because the system call only requires listing the file descriptors of interest, while select() builds a bitmap, turns on bits for the fds of interest, and then afterward the whole bitmap has to be linearly scanned again. select() is O(highest file descriptor), while poll() is O(number of file descriptors).

区别在于poll() syscall的scalability更好。
poll()只维护感兴趣的fd列表，但是select() syscall通过bitmap来维护整个fd列表。poll()和select()的时间复杂度分别为O(fd数目)和O(最大fd数目).

[5]中认为：

select最早于1983年出现在4.2BSD中，它通过一个select()系统调用来监视多个文件描述符的数组
poll在1986年诞生于System V Release 3，它和select在本质上没有多大差别，但是poll没有最大文件描述符数量的限制。

??说好的scalability区别呢？

# References

1. pyhton基础教程(第2版)
2. [socket阻塞与非阻塞，同步与异步、I/O模型](http://blog.csdn.net/hguisu/article/details/7453390)
3. https://docs.python.org/2/library/socket.html
4. https://docs.python.org/2/library/select.html
5. http://www.cnblogs.com/coser/archive/2012/01/06/2315216.html
