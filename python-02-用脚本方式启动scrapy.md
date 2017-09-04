---
layout: post
title: 用脚本方式启动scrapy
date: 2017-09-04 12:00:00
comments: true
external-url:
categories: [爬虫]
---

众所周知，直接通过命令行`scrapy crawl yourspidername`可以启动项目中名为yourspidername的爬虫。在python脚本中可以调用cmdline模块来启动命令行：

```py
$ cat yourspider1start.py
from scrapy import cmdline
cmdline.execute('scrapy crawl yourspidername'.split())
```

也可以通过shell脚本每隔2秒启动所有爬虫：
```sh
$ cat startspiders.sh
#!/usr/bin/env bash
count=0
while [ $count -lt $1 ];
do
  sleep 2 
  nohup python yourspider1start.py >/dev/null 2>&1 &
  nohup python yourspider2start.py >/dev/null 2>&1 &
  let count+=1
done
```

以上方法本质上都是启动scrapy命令行。如何通过调用scrapy内部函数，在编程方式下启动爬虫呢？

[官方文档](http://scrapy.readthedocs.io/en/latest/topics/practices.html)给出了两个scrapy工具：

1. scrapy.crawler.CrawlerRunner, runs crawlers inside an already setup Twisted reactor
2. scrapy.crawler.CrawlerProcess, 父类是CrawlerRunner

scrapy框架基于Twisted异步网络库，CrawlerRunner和CrawlerProcess帮助我们从Twisted reactor内部启动scrapy。

直接使用CrawlerRunner可以更精细的crawler进程，要手动指定Twisted reactor关闭后的回调函数。指定如果不打算在应用程序中运行更多的Twisted reactor，使用子类CrawlerProcess则更合适。

下面简单是文档中给的用法示例：

```py
# encoding: utf-8
__author__ = 'fengshenjie'
from twisted.internet import reactor
from scrapy.utils.project import get_project_settings

def run1_single_spider():
    '''Running spiders outside projects
    只调用spider，不会进入pipeline'''
    from scrapy.crawler import CrawlerProcess
    from scrapy_test1.spiders import myspider1
    process = CrawlerProcess({
        'USER_AGENT': 'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)'
    })

    process.crawl(myspider1)
    process.start()  # the script will block here until the crawling is finished

def run2_inside_scrapy():
    '''会启用pipeline'''
    from scrapy.crawler import CrawlerProcess
    process = CrawlerProcess(get_project_settings())
    process.crawl('spidername') # scrapy项目中spider的name值
    process.start()

def spider_closing(arg):
    print('spider close')
    reactor.stop()

def run3_crawlerRunner():
    '''如果你的应用程序使用了twisted，建议使用crawlerrunner 而不是crawlerprocess
    Note that you will also have to shutdown the Twisted reactor yourself after the spider is finished. This can be achieved by adding callbacks to the deferred returned by the CrawlerRunner.crawl method.
    '''
    from scrapy.crawler import CrawlerRunner
    runner = CrawlerRunner(get_project_settings())

    # 'followall' is the name of one of the spiders of the project.
    d = runner.crawl('spidername')
    
    # stop reactor when spider closes
    # d.addBoth(lambda _: reactor.stop())
    d.addBoth(spider_closing) # 等价写法

    reactor.run()  # the script will block here until the crawling is finished

def run4_multiple_spider():
    from scrapy.crawler import CrawlerProcess
    process = CrawlerProcess()

    from scrapy_test1.spiders import myspider1, myspider2
    for s in [myspider1, myspider2]:
        process.crawl(s)
    process.start()

def run5_multiplespider():
    '''using CrawlerRunner'''
    from twisted.internet import reactor
    from scrapy.crawler import CrawlerRunner
    from scrapy.utils.log import configure_logging

    configure_logging()
    runner = CrawlerRunner()
    from scrapy_test1.spiders import myspider1, myspider2
    for s in [myspider1, myspider2]:
        runner.crawl(s)

    d = runner.join()
    d.addBoth(lambda _: reactor.stop())

    reactor.run()  # the script will block here until all crawling jobs are finished

def run6_multiplespider():
    '''通过链接(chaining) deferred来线性运行spider'''
    from twisted.internet import reactor, defer
    from scrapy.crawler import CrawlerRunner
    from scrapy.utils.log import configure_logging
    configure_logging()
    runner = CrawlerRunner()

    @defer.inlineCallbacks
    def crawl():
        from scrapy_test1.spiders import myspider1, myspider2
        for s in [myspider1, myspider2]:
            yield runner.crawl(s)
        reactor.stop()

    crawl()
    reactor.run()  # the script will block here until the last crawl call is finished


if __name__=='__main__':
    # run4_multiple_spider()
    # run5_multiplespider()
    run6_multiplespider()
```

# References


1. [编程方式下运行 Scrapy spider](http://wuchong.me/blog/2015/05/22/running-scrapy-programmatically/), 基于scrapy1.0版本
