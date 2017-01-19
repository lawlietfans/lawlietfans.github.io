---
layout: post
title: Apache Thrift概念以及快速入门
date: 2017-01-18 12:00:00
comments: true
external-url:
categories: [thrift, RPC]
---

本文简要介绍了thrift的背景、相关概念以及安装流程。并给出了C++以及python版本的入门例子。其中背景概念部分翻译自[1]。

<!--more-->

# 1 Krzysztof Rakowski的Apache Thrift介绍 [1]

# 2 安装

1、[安装依赖项](http://thrift.apache.org/docs/install/)，官方给出了不同系统下的依赖项安装步骤。

2、编译源代码，安装

```sh
# github mirror: https://github.com/apache/thrift
git clone https://git-wip-us.apache.org/repos/asf/thrift.git
cd thrift
./bootstrap.sh

# 禁用lua语言，查看更多参数：./configure --help
./configure --with-lua=no

# 编译
make
# 安装
sudo make install
```

configure这一步结束会在terminal输出对不同语言的支持信息，检查一下是否满足自己要求。
```sh
Building Plugin Support ...... : yes
Building C++ Library ......... : yes
Building C (GLib) Library .... : no
Building Java Library ........ : no
Building C# Library .......... : no
Building .NET Core Library ... : no
Building Python Library ...... : yes
Building Ruby Library ........ : no
Building Haxe Library ........ : no
Building Haskell Library ..... : no
Building Perl Library ........ : no
Building PHP Library ......... : yes
Building Dart Library ........ : no
Building Erlang Library ...... : no
Building Go Library .......... : no
Building D Library ........... : no
Building NodeJS Library ...... : no
Building Lua Library ......... : no

C++ Library:
   Build TZlibTransport ...... : yes
   Build TNonblockingServer .. : yes
   Build TQTcpServer (Qt4) .... : no
   Build TQTcpServer (Qt5) .... : no

Python Library:
   Using Python .............. : /usr/bin/python
   Using Python3 ............. : /usr/local/bin/python3
```

如果make这一步出现缺少.a文件的问题：

`g++: error: /usr/lib64/libboost_unit_test_framework.a: No such file or directory`

首先检查上一步的依赖项有没有全部安装，没问题的话可以看看`/usr/local/lib/`下有没有该文件，再拷贝到make过程中所寻找的路径下。

```sh
$ ls /usr/local/lib/libboost_unit_test_framework.*
/usr/local/lib/libboost_unit_test_framework.a
/usr/local/lib/libboost_unit_test_framework.so
/usr/local/lib/libboost_unit_test_framework.so.1.53.0

$ ls /usr/lib64/libboost_unit_test_framework*
/usr/lib64/libboost_unit_test_framework-mt.so         /usr/lib64/libboost_unit_test_framework.so
/usr/lib64/libboost_unit_test_framework-mt.so.1.53.0  /usr/lib64/libboost_unit_test_framework.so.1.53.0

$ make -n | grep libboost_unit_test_framework
/bin/sh ../../../libtool  --tag=CXX   --mode=link g++ -Wall -Wextra -pedantic -g -O2 -std=c++11 -L/usr/lib64  -o processor_test processor/ProcessorTest.o processor/EventLog.o processor/ServerThread.o libprocessortest.la ../../../lib/cpp/libthrift.la ../../../lib/cpp/libthriftnb.la /usr/lib64/libboost_unit_test_framework.a -L/usr/lib64 -levent -lrt -lpthread

$ sudo cp /usr/local/lib/libboost_unit_test_framework.a /usr/lib64/
$ make
no error.
```


3、验证

```sh
$ thrift -version
Thrift version 1.0.0-dev
$ which thrift
/usr/local/bin/thrift
```

# 3 入门例子

编写一个简单的thrift文件，定义相乘函数
```sh
$ ls
multiplication.thrift
$ cat multiplication.thrift
namespace py tutorial

service MultiplicationService
{
    i32 multiply(1:i32 n1, 2:i32 n2),
}
```

## 3.1 C++ server和client
编译生成c++代码
```sh
$ thrift --gen cpp multiplication.thrift

$ ls -R 
.:
gen-cpp  multiplication.thrift

./gen-cpp:
multiplication_constants.cpp    MultiplicationService.h    multiplication_types.h
multiplication_constants.h      MultiplicationService_server.skeleton.cpp
MultiplicationService.cpp       multiplication_types.cpp
```

接下来修改官方模版skeleton.cpp[4]
```sh
$ mv MultiplicationService_server.skeleton.cpp server.cpp
只需要修改server.cpp中int32_t multiply(const int32_t n1, const int32_t n2)函数
$ cat server.cpp
...
  int32_t multiply(const int32_t n1, const int32_t n2) {
    // Your implementation goes here
    return n1*n2;
  }
...
```


然后编写client.cpp
```cpp
#include "MultiplicationService.h"
#include <thrift/transport/TSocket.h>
#include <thrift/transport/TBufferTransports.h>
#include <thrift/protocol/TBinaryProtocol.h>

#include <iostream>
using namespace std;

using namespace apache::thrift;
using namespace apache::thrift::protocol;
using namespace apache::thrift::transport;

int main(int argc, char *argv[]) {
  boost::shared_ptr<TSocket> socket(new TSocket("localhost", 9090));
  boost::shared_ptr<TTransport> transport(new TBufferedTransport(socket));
  boost::shared_ptr<TProtocol> protocol(new TBinaryProtocol(transport));

  int res=0;
  MultiplicationServiceClient client(protocol);
  transport->open();
  res = client.multiply(10,10);
  cout << "res "<<res<<endl;
  transport->close();
  return 0;
}
```

编译源码
```sh
$ g++ -c MultiplicationService.cpp
$ g++ -c multiplication_constants.cpp multiplication_types.cpp server.cpp
$ g++ -lthrift *.o -o server.exe
$ g++ -c MultiplicationService.cpp multiplication_constants.cpp multiplication_types.cpp client.cpp
$ g++ -lthrift *.o -o client.exe

$ ls -R 
.:
gen-cpp  multiplication.thrift

./gen-cpp:
client.cpp  multiplication_constants.cpp  MultiplicationService.cpp  multiplication_types.cpp  server.cpp
client.exe  multiplication_constants.h    MultiplicationService.h    multiplication_types.h    server.exe
client.o    multiplication_constants.o    MultiplicationService.o    multiplication_types.o    server.o
```

运行
```sh
shell 1> ./server.exe
shell 2> ./client.exe
res 100
```

如果运行server.exe出现找不到共享库的错误，[解决办法](http://www.cnblogs.com/davidyang2415/archive/2012/03/28/2421158.html)如下：
```sh
$ ./server 
./server: error while loading shared libraries: libthrift-1.0.0-dev.so: cannot open shared object file: No such file or directory
$ sudo find / -name "libthrift*so" #where is your libthrift
/usr/local/lib/libthrift-1.0.0-dev.so
/usr/local/lib/libthrift.so
...
$ echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib/:/usr/lib/" >> ~/.bashrc  #set env var
$ . ~/.bashrc  #reload
```

## 3.2 python server和client
生成python代码
```sh
$ thrift --gen py multiplication.thrift
$ ls -R gen-py
./gen-py:
__init__.py  tutorial

./gen-py/tutorial:
constants.py  __init__.pyc              MultiplicationService.pyc     ttypes.py
__init__.py   MultiplicationService.py  MultiplicationService-remote  ttypes.pyc
```

创建server.py和client.py

server.py
```py
import glob
import sys
sys.path.append('gen-py')
sys.path.insert(0, glob.glob('../../lib/py/build/lib*')[0])
from tutorial import MultiplicationService
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol
from thrift.server import TServer

class MultiplicationServiceHandler(MultiplicationService.Iface):
    def __init__(self):
        self.log = {}

    def multiply(self, n1, n2):
        print('multiply(%d,%d)' % (n1,n2))
        return n1*n2

if __name__ == '__main__':
    handler = MultiplicationServiceHandler()
    processor = MultiplicationService.Processor(handler)
    transport = TSocket.TServerSocket(port=9090)
    tfactory = TTransport.TBufferedTransportFactory()
    pfactory = TBinaryProtocol.TBinaryProtocolFactory()

    server = TServer.TSimpleServer(processor, transport, tfactory, pfactory)

    # You could do one of these for a multithreaded server
    # server = TServer.TThreadedServer(
    #     processor, transport, tfactory, pfactory)
    # server = TServer.TThreadPoolServer(
    #     processor, transport, tfactory, pfactory)

    print('Starting the server...')
    server.serve()
```

client.py
```py
import sys
import glob
sys.path.append('gen-py')
sys.path.insert(0, glob.glob('../../lib/py/build/lib*')[0])

from tutorial import MultiplicationService
from thrift import Thrift
from thrift.transport import TSocket
from thrift.transport import TTransport
from thrift.protocol import TBinaryProtocol

def main():
    transport = TSocket.TSocket('localhost', 9090)
    # Buffering is critical. Raw sockets are very slow
    transport = TTransport.TBufferedTransport(transport)
    # Wrap in a protocol
    protocol = TBinaryProtocol.TBinaryProtocol(transport)
    # Create a client to use the protocol encoder
    client = MultiplicationService.Client(protocol)
    # Connect!
    transport.open()
    print(client.multiply(10,10))
    # Close!
    transport.close()

if __name__ == '__main__':
    try:
        main()
    except Thrift.TException as tx:
        print('%s' % tx.message)
```

```sh
$ chmod a+x server.py
$ chmod a+x client.py

shell 1> ./server.py
Starting the server...
multiply(10,10)
shell 2> ./client.py
100
```

python client使用C++ server提供的服务
```sh
shell 1> ./server.exe
shell 2> ./client.py
100
```

# References

1. http://www.thrift.pl/
2. http://thrift.apache.org/
3. http://thrift-tutorial.readthedocs.io
4. http://roclinux.cn/?p=3316
