---
title: "自引用函数和配置设计"
description: 
date: 2022-03-20T03:30:25+08:00
image: 
math: 
license: 
hidden: false
comments: true
draft: false
tags:
categories:
---

最近发现一篇文章[*Self-referential functions and the design of options*](https://commandcenter.blogspot.com/2014/01/self-referential-functions-and-design.html)介绍了一种很好的实现配置的方式，目前这种方式
在许多的开源库中被使用，比如GRPC：

```go
conn, err := grpc.Dial(*addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
```

## 例子

首先定义一个配置接口：

```go
type option func(*Foo)
```

这里`Foo`就是我们需要实际操作的对象

之后我们实现一个加载配置的方法：

```go
func (f *Foo) Option(opts ...option) {
    for _, opt := range opts {
        opt(f)
    }
}
```

 这里通过变长参数的方式将所有的option执行。

 下面实现一个具体的配置项：

 ```go
func Verbosity(v int) option {
    return func(f *Foo) {
        f.verbosity = v
    }
}
```

通过闭包的方式构造一个option的函数，最后调用：

```go
foo.Option(pkg.Verbosity(3))
```

当然最后可以依据实际情况进行改造，原文中还对这种方法做了一点改进，这里就不说了，个人感觉grpc这种方式已经够大部分场景下使用了。
