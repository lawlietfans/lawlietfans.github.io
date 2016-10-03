OUTLINE

- udp和tcp区别
- udp遇见包丢失怎么办，设计一下
- udp的包如果出现错误怎么办？上层保证吗
	- 差错检测可以百分百检错吗
	- 有哪些校验和计算方法

- TCP如何保证可靠传输、沾包
- Linux下高并发socket最大连接数
	- linux下高性能网络框架，一个服务器连成千上万socket怎么办
- RFID项目中服务器需要连多个客户，如何receive消息。

# 1 UDP和TCP区别

网络层为主机之间提供逻辑通信，运输层为应用进程之间提供端到端的逻辑通信。[1]

根据应用程序的不同需求，运输层需要两种协议：
- 面向连接的TCP（transmission control protocol）协议
- 无连接的UDP（User datagram protocol）协议


两者区别在于：
- UDP是无连接的，TCP是面向连接的
- UDP尽最大努力交付报文，TCP保证可靠交付。
- UDP是基于报文的，并不合并或拆分上层交下来的报文，而是添加首部后交给IP层。TCP是基于byte流的。

[2]中用了更多的角度比较：

UDP是message-based无连接协议，也就是发送数据之前不需要建立专用的端到端连接。传输数据的时候也不需要检查接收方的readiness和状态。

- 1）不保证交付

UDP message发送之后便无法知道其状态了，有可能顺利到达接收方，也可能丢失。UDP没有确认收到、重传、超时这些概念。

- 2）无序的
- 3）轻量级，只是在IP的数据报服务之上增加了很少一点功能[1]
- 4）datagrams

Packets相互独立发送，并且各自有明确的边界。如果发送方一个packet，那接收方一定原样收到。

- 5）无拥塞控制

UDP本身不提供拥塞控制，如有必要，拥塞控制方法应该在应用层实现。

- 6）支持广播

而TCP是connection-oriented协议。意味着通信之前必须通过三次握手建立端到端连接。连接建立后，双方都可以通过这个连接发送数据。特点是

- 1）可靠交付

这里的可靠只限于传输层。在应用层，仍然需要一个独立的acknowledgement flow control。

TCP管理message确认、重传和超时。
>这里提到If it gets lost along the way, the server will re-request the lost part.这和[1]中提到可靠传输过程不符：
>接收方不需要请求重传某个出错的分组。因为发送方每发完一个分组会设置一个超时计时器，如果超时计时器到期，发送方没有收到接收方对前一个分组的确认。那么发送方会自动重传。

在TCP中只有两种情况：1. 所有数据正确发送 2. 网络已经断掉，超时多次。

- 2）有序的
- 3）重量级，支持可靠交付和拥塞控制
- 4）数据以stream的方式读入。没有message（segment）的明显边界

## 1.1 辨析data、packet、datagram、message、segment、frame
data的范围最广，什么都可以叫做data，说发送data肯定是不会错的。

首先讨论这些名词的联系，他们都可以叫做PDU（protocol data unit）[3]，也就是通信协议使用的数据单元。
>[1]中使用的是TPDU（transport protocol data unit）。

所以他们的区别在于所在的协议不同。

![](https://qph.ec.quoracdn.net/main-qimg-56e3b52fd6160b0c3874c3cf2032790f)

在传输层叫segment（报文段）

在网络层叫datagram（数据报）

在数据链路层叫frame（帧）

他们可以统称为packet（分组）。

个人认为message和packet同义，比如[3]中这几句可以证明：
>But in other cases the term "segment" includes the whole TCP message, including the TCP headers.
>A single whole IP message is a "datagram".
The original IP RFC refers to link-layer messages as "packets".

# 2 包丢失的处理

UDP不保证可靠交付，像拥塞控制一样，如有需要应该由应用层实现。

# 3 差错检测

数据从发送方到接收方可能会产生一些随即错误，差错检测指检测出错误数据[4]。

而纠错的方式有两种：
- 1）Automatic repeat request (ARQ)，网络中用的这种。
- 2）Forward error correction (FEC)

差错检测方式（Error detection schemes）包括：
- 1	Repetition codes
- 2	Parity bits
- 3	Checksums
- 4	Cyclic redundancy checks (CRCs)
- 5	Cryptographic hash functions
- 6	Error-correcting codes

其中checksum是通过某种算术公式把原始数据算出算术和。

CRC是不安全的哈希函数，用来检测数据中随机错误。

UDP和TCP的校验和不仅要对整个IP协议负载(包括UDP/TCP协议头和UDP/TCP协议负载)进行计算，还要先对一个伪协议头进行计算：先要填充伪首部各个字段，然后再将UDP/TCP报头及之后的数据附加到伪首部的后面，再对伪首部使用校验和计算，所得到的值才是UDP/TCP报头部分的校验和。[5]

具体计算方法是：

1）首先把校验和字段清零；

2）然后对每 16 位（2 字节）进行二进制反码求和；

反码求和时，最高位的进位要进到最低位，也就是循环进位。

接收方进行校验：按二进制反码求这些16bit字的和。若不差错，结果应为全1

# 4 TCP可靠传输

通过停止等待协议、超时重传机制、滑动窗口来说保证。

连续ARQ协议是滑动窗口的简化模型。

# 5 Linux下高并发socket最大连接数[6]

去除各种限制后，理论上单独一个进程最多可以同时建立60000多个TCP客户端连接

[6]中总结了去除各种限制的方法

- 1）用户进程可打开文件数限制

在Linux平台上，无论编写客户端程序还是服务端程序，在进行高并发TCP连接处理时，最高的并发数量都要受到系统对用户单一进程同时可打开文件数量的限制(这是因为系统为每个TCP连接都要创建一个socket句柄，每个socket句柄同时也是一个文件句柄)。

- 2）网络内核对TCP连接的有关限制
	- 内核对本地端口号范围的限制
	- Linux网络内核的`IP_TABLE`防火墙对最大跟踪的TCP连接数的限制

- 3）使用支持高并发网络I/O的编程技术

在Linux上编写高并发TCP连接应用程序时，必须使用合适的网络I/O技术和I/O事件分派机制。

# 6 RFID项目中对多个socket的处理

## 6.1 一个完整的TCP客户-服务端程序需要的基本socket函数

在APUE中[7],C++版本socket函数如下：
- 1 `int socket(int domain, int type, int protocol);`

domain: `AF_INET/AF_INET6/AF-UNIX/AF_UPSPEC` 协议域，又称协议族

type: `SOCK_DGRAM / SOCK_RAW / SOCK_SEQPACKET / SOCK_STREAM`　规定数据的传输方式

protocol: `IPPROTO_IP/IPPROTO_IPV6/IPPROTO_ICMP/IPPROTO_RAW/IPPROTO_TCP/IPPROTO_UDP` 指定为因特网域套接字定义的协议，通常为０，自动选择type类型对应的默认协议。

- 2 `int bind(int sockfd, const struct sockaddr *addr, socklen_t len);`

把本地协议地址赋给socket

- 3 `int listen(int sockfd, int backlog);` //only called by server

backlog 指定最大允许接入的连接数量。

- 4 `int connect(int sockfd, const struct sockaddr *addr, socklen_t len);` //only called by client
- 5 `int accept(int sockfd, struct sockaddr *restrict addr, socklen_t *restrict len);` //only called by server
- 6 `int close(int fg);`
- 7 `int shutdown(int sockfd, int howto);`

对于于[8]和[9]中的C#版函数如下：
- 1 `Socket(AddressFamily, SocketType, ProtocolType);`
- 2 `socketobj.Bind(IPEndPoint);`
- 3 `socketobj.Listen(int);`
- 4 `socketobj.Connect(IPEndPoint);`
- 5 `socketobj.Accept();`
- 6 不好意思我忘记怎么关闭了

## 6.2 [8]和[9]原理图示

[8]是单用户模式，server只能连一个client，当连接建立后，server便不在监听。

双方都需要两个线程Threc用来接收报文，Thsend用来发送报文。

![](http://images2015.cnblogs.com/blog/631533/201610/631533-20161003113516160-278103834.png)

要改成[9]中的多用户模式只需要保持server的监听状态，接着对每个新连接成功的client，都有配套的socket、Threc、Thsend。

我们用string类型的endpoint来标识每个client，endpoint格式为：`ip:port`

我们只需要把`endpoint`作为key，`socket、Threc、Thsend`作为value存在字典里面就可以灵活处理每个每个socket连接了。

![](http://images2015.cnblogs.com/blog/631533/201610/631533-20161003114107879-639346930.png)


# References

- 1 谢希仁. 计算机网络
- 2 [UDP](https://en.wikipedia.org/wiki/User_Datagram_Protocol)
- 3 https://www.quora.com/What-is-the-difference-between-datagrams-and-segments-in-the-TCP-IP-and-OSI-models
- 4 [Error detection and correction](https://en.wikipedia.org/wiki/Error_detection_and_correction#Definitions)
- 5 http://www.cnblogs.com/linyx/p/3609043.html
- 6 http://blog.csdn.net/guowake/article/details/6615728 
- 7 [apue读书笔记之socket](http://blog.csdn.net/ccbird88/article/details/6424700)
- 8 https://my.oschina.net/SnifferApache/blog/406563
- 9 https://my.oschina.net/SnifferApache/blog/413470
