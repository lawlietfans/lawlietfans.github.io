---
layout: post
title: golang中处理panic的正确姿势
date: 2018-08-24 12:00:00
comments: true
external-url:
categories: [howto]
---

golang中panic的处理没有其他语言中try-catch语法那么简单。
大部分例子的panic处理都是在退出环节。那么如何在正常业务流程中处理panic，然后不影响全局呢？

```go
// 业务处理1，定义myStrcture

isDone := make(chan int)
go func() {
    defer func() {
        if err := recover(); err != nil {
            log.E(this.Ctx, "Skip panic", "tmpInfo=[%+v]", tmpInfo)
        }
        isDone <- 1
    }()
    myStrcture.Ip = tmpInfo.Ip
    myStrcture.Country = tmpInfo.Address.Country.Name //可能panic
    myStrcture.Province = tmpInfo.Address.Province.Name
    myStrcture.City = tmpInfo.Address.City.Name
    myStrcture.District = tmpInfo.Address.District.Name
}()
<-isDone

// 业务处理2
// 返回 myStrcture
```

# References

1. [关于golang的panic recover异常错误处理](http://xiaorui.cc/2016/03/09/%E5%85%B3%E4%BA%8Egolang%E7%9A%84panic-recover%E5%BC%82%E5%B8%B8%E9%94%99%E8%AF%AF%E5%A4%84%E7%90%86/)
