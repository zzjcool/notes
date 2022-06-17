---
title: "使用git-crypt对Git仓库中的敏感文件进行加密"
description: 加密Git仓库中的密钥等敏感数据
date: 2022-06-16T23:10:49+08:00
image: 
math: 
license: 
hidden: false
comments: true
draft: false
tags:
categories:
  - 笔记
---

# 使用git-crypt对Git仓库中的敏感文件进行加密

## 安装

依赖：

|                                  | Debian/Ubuntu package | RHEL/Centos package |
| -------------------------------- | --------------------- | ------------------- |
| Make                             | make                  | make                |
| A C++11 compiler (e.g. gcc 4.9+) | g++                   | gcc-c++             |
| OpenSSL development files        | libssl-dev            | openssl-devel       |

有以上依赖后可以安装git-crypt

```bash
#!/bin/sh
# install git-crypt
mkdir ~/tmp
cd ~/tmp

git clone https://github.com/AGWA/git-crypt.git
cd git-crypt
make
make install

# clean
rm -rf ~/tmp
```

mac 安装：

```bash
brew install git-crypt
```

## 加密

git-crypt 初始化：

```bash
git-crypt init
```

## 配置需要加密的文件

在项目根目录中创建`.gitattributes`文件，这个文件可以设置哪些文件需要加密

```text
*.go filter=git-crypt diff=git-crypt
*.yaml filter=git-crypt diff=git-crypt
template.md filter=git-crypt diff=git-crypt
output.md filter=git-crypt diff=git-crypt
code/** filter=git-crypt diff=git-crypt
```

可以自定义需要加密的具体文件或者指定文件格式的文件或者是整个目录加密。

## 导出密钥

```bash
git-crypt export-key ./git-crypt-key
```

在`.gitignore`中加入`git-crypt-key`来忽略key文件

导出的密钥需要另外存放并且妥善保管，也可以使用base64编码key文件为文本格式：

```bash
cat git-crypt-key | base64

# 需要导入密钥的时候可以解码base64

echo "<git-crypt-key 的base64编码>" | base64 -d > git-crypt-key
```

## 解密

解密需要有之前加密的key文件git-crypt-key

```bash
git-crypt unlock ./git-crypt-key
```

对于每个仓库之需要执行一次即可。
