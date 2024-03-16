## 简介

[**1Panel**](https://github.com/1Panel-dev/1Panel) 是一个现代化、开源的 Linux 服务器运维管理面板。

偶然看到 [**docker-1panel**](https://github.com/okxlin/docker-1panel) 和 [**1panel-dood**](https://github.com/tangger2000/1panel-dood) 将 1Panel 部署到容器的办法，便进行了尝试，发现 1Panel 运行良好，完全可以将 1Panel 放在容器里面运行。

和上面两个仓库实现的方式不一样，[**1panel-in-docker**](https://github.com/Xeath/1panel-in-docker) 是通过增加一个假冒的 systemctl 实现可通过官方安装脚本安装 1Panel。

***

## 1. 注意事项

由于容器内部 `systemd` 限制，1Panel 可能有部分功能不完善。另外 1Panel 官方只提供 `amd64`、`arm64`、`armv7`、`ppc64le`、`s390x` 这些指令集，所以目前只提供这些镜像。

## 2. 相关设置

### 2.1 环境变量

  - 时区设置 `TZ=Asia/Shanghai`

> **以下变量为首次启动安装的过程根据需求设置**

  - 安装目录 `PANEL_BASE_DIR=/opt`（默认：/opt）
  - 面板端口 `PANEL_PORT=8888`（默认：随机）
  - 管理账户 `PANEL_USERNAME=admin`（默认：随机）
  - 管理密码 `PANEL_PASSWORD=admin888`（默认：随机）

### 2.2 挂载目录

  - 数据目录 `/opt:/opt`

**根据自己的需求修改，建议容器内目录保持默认**

#### 2.2.1 Docker

  - 套接字 `/var/run/docker.sock:/var/run/docker.sock`
  - 存储卷 `/var/lib/docker/volumes:/var/lib/docker/volumes`

#### 2.2.2 Podman

  - 套接字 `/run/podman/podman.sock:/var/run/docker.sock`
  - 存储卷 `/var/lib/containers/storage/volumes:/var/lib/docker/volumes`

## 3. 部署方式

### 3.1 Docker

#### 3.1.1 命令行

```
docker run -d \
    --name 1panel \
    --restart always \
    --network host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker/volumes:/var/lib/docker/volumes \
    -v /opt:/opt \
    -e TZ=Asia/Shanghai \
    moelin/1panel:latest
```

#### 3.1.2 部署文件

创建一个 `docker-compose.yml` 文件，内容类似如下
```
version: '3'
services:
  1panel:
    container_name: 1panel # 容器名
    restart: always
    network_mode: "host"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/volumes:/var/lib/docker/volumes
      - /opt:/opt
    environment:
      - TZ=Asia/Shanghai
    image: moelin/1panel:latest
    labels:  
      createdBy: "Apps"
```

然后 `docker-compose up -d` 运行

### 3.2 Podman

#### 3.1.1 命令行

```
podman run -d \
    --name 1panel \
    --restart always \
    --network host \
    -v /run/podman/podman.sock:/var/run/docker.sock \
    -v /var/lib/containers/storage/volumes:/var/lib/docker/volumes \
    -v /opt:/opt \
    -e TZ=Asia/Shanghai \
    moelin/1panel:latest
```

#### 3.1.2 部署文件

创建一个 `docker-compose.yml` 文件，内容类似如下
```
version: '3'
services:
  1panel:
    container_name: 1panel # 容器名
    restart: always
    network_mode: "host"
    volumes:
      - /run/podman/podman.sock:/var/run/docker.sock
      - /var/lib/containers/storage/volumes:/var/lib/docker/volumes
      - /opt:/opt
    environment:
      - TZ=Asia/Shanghai
    image: moelin/1panel:latest
    labels:  
      createdBy: "Apps"
```

然后 `podman-compose up -d` 运行
