---
title: "Nginx 相关配置"
description: 
date: 2022-01-07T10:33:38+08:00
image: 
math: 
license: 
hidden: false
comments: true
draft: false
tags:
  - Nginx
categories:
---
## Docker启动Nginx

可以使用docker-compose快速的启动Nginx
docker-compose.yaml文件：

```yaml
version: '3'
services:
  nginx:
    image: nginx
    container_name: nginx
    network_mode: "host"
    volumes:
      - ./nginx:/etc/nginx/conf.d
    restart: unless-stopped
```

可以在当前目录下的nginx目录添加任意配置

## Nginx 反向代理Websocket

```nginx
    server {
        listen 48265;
        server_name "";
        location / {
        proxy_pass http://domain:48265;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Host $host;
        proxy_set_header Connection "Upgrade";
        }
    }
```

最后一行配置可以转发ws

有时候我们的nginx反向代理会出错，但是我们检查发现上游服务器是正常的，那这可能
是因为反向代理后端发生dns解析的变动（如k8s服务重启或者ddns），所以
需要配置nginx的dns解析（resolver 8.8.8.8），同时反向代理的后端地址需要写为变量：

```nginx
    server {
        listen 48265;
        server_name "";


        resolver 119.29.29.29 8.8.8.8 valid=30s;
        set $proxy_pass_url http://domain:48265;
        location / {
        proxy_pass $proxy_pass_url;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Host $host;
        proxy_set_header Connection "Upgrade";
        }
    }
```

## Nginx 直接显示系统目录

```nginx
server {
    listen       8880;
    listen       [::]:8880;
    server_name  domain.com;


    location /
    {
       root /data;
       autoindex on;
       autoindex_exact_size off;
       autoindex_localtime on;
       charset utf-8,gbk;
    }

}
```

其中`root /data`表示实际的目录位置
