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

```conf
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

最后两行配置可以转发ws
