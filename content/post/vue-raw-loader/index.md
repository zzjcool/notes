---
title: "Vue 加载文件为文本格式"
description: 
date: 2022-11-06T22:37:04+08:00
image: 
math: 
license: 
hidden: false
comments: true
draft: false
tags:
  - Vue
categories:
  - 笔记
---
# Vue 加载文件为文本格式

使用Vue开发的时候，我们可能需要读取文本文件，这个时候需要使用`raw-loader`

## 安装

```bash
npm install raw-loader --save-dev
```

## 使用

这里以读取yaml文件为例：

```bash
const foo = require('!raw-loader!pages/template/foo.yaml')
console.log(foo.default)
```
