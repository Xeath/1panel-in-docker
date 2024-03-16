# 使用 Ubuntu 22.04 作为基础镜像
FROM ubuntu:22.04

# 设置时区为亚洲/上海
ENV TZ=Asia/Shanghai

# 设置工作目录为/app
WORKDIR /app

# 复制必要的文件
COPY ./init.sh .

# 设置文件权限
RUN chmod +x ./init.sh

# 设置工作目录为根目录
WORKDIR /

# 创建 Docker 套接字的卷
VOLUME /var/run/docker.sock

# 启动
CMD ["/bin/bash", "/app/init.sh"]
