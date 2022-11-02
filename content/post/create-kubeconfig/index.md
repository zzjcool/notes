---
title: "Kubernetes创建普通用户kubeconfig"
description: 
date: 2022-11-02T19:21:47+08:00
image: 
math: 
license: 
hidden: false
comments: true
draft: false
tags:
categories:
---

# Kubernetes创建普通用户kubeconfig

提供kubernetes集群管理权限的方式包括使用kubeconfig以及serviceaccount，其中kubeconfig常用于在集群外部使用kubectl对集群进行调用。

这里记录一下创建kubeconfig的方法。

## 创建私钥

这里以创建用户`myuser`为例

```bash
openssl genrsa -out myuser.key 2048
openssl req -new -key myuser.key -out myuser.csr
```

其中`Organization Name`表示用户所属的组，`Common Name`为用户

## 创建CertificateSigningRequest

需要使用kubectl创建证书签名请求

```bash
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: myuser
spec:
  request: <CSR 文件内容的 base64 编码值。 要得到该值，可以执行命令 cat myuser.csr | base64 |>
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

```

通过kubectl创建了myuser用户的证书签发请求


## 批准证书

查看当前的证书签名请求
```bash
kubectl get csr
```

批准请求
```bash
kubectl certificate approve myuser
```

## 获取证书

将证书输出到myuser.crt中
```bash
kubectl get csr myuser -o jsonpath='{.status.certificate}'| base64 -d > myuser.crt
```

## 创建角色和角色绑定

如果是集群范围使用ClusterRole和ClusterRoleBinding，命名空间的使用Role和RoleBinding

将用户myuser和Role绑定。


## 添加到kubeconfig

```bash
# 添加用户凭据
kubectl config set-credentials myuser --client-key=myuser.key --client-certificate=myuser.crt --embed-certs=true
# 设置上下文
kubectl config set-context myuser --cluster=kubernetes --user=myuser
# 使用上下文
kubectl config use-context myuser
```

这里上下文的集群kubernetes需要替换成自己的集群