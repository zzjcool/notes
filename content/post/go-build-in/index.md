---
title: "Golang 内置包常用方法"
description: 记录一些常用的写法
date: 2022-01-04T19:43:41+08:00
image: 
math: 
license: 
hidden: false
comments: true
draft: false
tags:
  - "Go"
categories:
  - "Go"
---

## net/url

### 添加query

原本有url:<http://domain.com>,
现在想要添加query参数变成:<http://domain.com?key=value>

可以自己写一个方法去添加query参数。

```go
func TestURL(t *testing.T) {
 api, err := url.Parse("http://domain.com")
 if err != nil {
  t.Fatal(err)
 }
 URLAddQuery(api, "key", "value")
 fmt.Println(api.String())
}

// URLAddQuery 提供一个URL，然后添加query参数
func URLAddQuery(addr *url.URL, key, value string) {
 query := addr.Query()
 query.Add(key, value)
 addr.RawQuery = query.Encode()
}
```

### url拼接path

```go
 api, err := url.Parse("http://domain.com")
 api.Path = "/api/test"
```
