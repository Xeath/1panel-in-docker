## 简介

[**1Panel**](https://github.com/1Panel-dev/1Panel) 是一个现代化、开源的 Linux 服务器运维管理面板。

偶然看到 [**docker-1panel**](https://github.com/okxlin/docker-1panel) 和 [**1panel-dood**](https://github.com/tangger2000/1panel-dood) 将 1Panel 部署到容器的办法，便进行了尝试，发现 1Panel 运行良好，完全可以将 1Panel 放在容器里面运行。

和上面两个仓库实现的方式不一样，[**1panel-in-docker**](https://github.com/Xeath/1panel-in-docker) 是通过增加一个仿冒的 systemctl 实现可通过官方安装脚本安装 1Panel。

***

## 1. 注意事项

1. 由于容器内部 `systemd` 限制，1Panel 可能有部分功能不完善；
2. 1Panel 官方只支持 `amd64`、`arm64`、`armv7`、`ppc64le`、`s390x` 等指令集；
3. 面板安装脚本在执行自动安装 Docker 可能会出现安装时间过长，重启容器让安装过程继续即可（可能需要多次）。

## 2. 相关设置

### 2.1 环境变量

  - 时区设置 `TZ=Asia/Shanghai`

> **以下变量为首次启动安装的过程根据需求设置**

  - 安装来源 `INSTALL_SOURCE=auto`（默认：auto 自动选择，可选 intl 使用 1panel.pro 的安装脚本，或 cn 使用 1panel.cn 的安装脚本）
  - 面板分支 `INSTALL_MODE=stable`（默认：stable 稳定分支，可选 dev 开发分支）
  - 安装目录 `PANEL_BASE_DIR=/opt`（默认：/opt）
  - 面板端口 `PANEL_PORT=8888`（默认：随机）
  - 安全入口 `PANEL_ENTRANCE=entrance`（默认：随机）
  - 管理账户 `PANEL_USERNAME=admin`（默认：随机）
  - 管理密码 `PANEL_PASSWORD=admin888`（默认：随机）

    首次启动未设置登录信息，请在安装完成后通过日志查询登录信息，或者首次启动使用 `-i` 即可在前台打印安装日志

### 2.2 挂载目录

  - 数据目录 `/opt:/opt`

    根据自己的需求修改

    **容器内目录和容器外目录路径需要保持一致！**

    **容器内目录和容器外目录路径需要保持一致！**

    **容器内目录和容器外目录路径需要保持一致！**

#### 2.2.1 Docker

  - Socket `/var/run/docker.sock:/var/run/docker.sock`
  - Docker `/var/lib/docker:/var/lib/docker`

#### 2.2.2 Podman

  - Socket `/run/podman/podman.sock:/var/run/docker.sock`
  - Podman `/var/lib/containers/storage:/var/lib/docker`

## 3. 部署方式

### 3.1 Docker

#### 3.1.1 命令行

```
docker run -dt \
    --name 1panel \
    --restart always \
    --network host \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/docker:/var/lib/docker \
    -v /opt:/opt \
    -e TZ=Asia/Shanghai \
    xeath/1panel-in-docker:latest
```

#### 3.1.2 编排部署

创建一个 `docker-compose.yml` 文件，内容类似如下
```
version: '3'
services:
  1panel:
    container_name: 1panel # 容器名
    restart: always
    network_mode: "host"
    tty: true
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker:/var/lib/docker
      - /opt:/opt
    environment:
      - TZ=Asia/Shanghai
    image: xeath/1panel-in-docker:latest
    labels:  
      createdBy: "Apps"
```

然后 `docker-compose up -dt` 运行

### 3.2 Podman
**Podman 虽然也可以运行，但是网络不支持 host，使用上存在一些问题**
#### 3.1.1 命令行

```
podman run -dt \
    --name 1panel \
    --restart always \
    --network bridge \
    -v /run/podman/podman.sock:/var/run/docker.sock \
    -v /var/lib/containers/storage:/var/lib/docker \
    -v /opt:/opt \
    -e TZ=Asia/Shanghai \
    xeath/1panel-in-docker:latest
```

#### 3.1.2 编排部署

创建一个 `docker-compose.yml` 文件，内容类似如下
```
version: '3'
services:
  1panel:
    container_name: 1panel # 容器名
    restart: always
    network_mode: "bridge"
    tty: true
    volumes:
      - /run/podman/podman.sock:/var/run/docker.sock
      - /var/lib/containers/storage:/var/lib/docker
      - /opt:/opt
    environment:
      - TZ=Asia/Shanghai
    image: xeath/1panel-in-docker:latest
    labels:  
      createdBy: "Apps"
```

然后 `podman-compose up -dt` 运行
