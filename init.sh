#!/bin/bash

# 首次启动环境变量
# 安装目录: PANEL_BASE_DIR
# 面板端口: PANEL_PORT
# 管理账户: PANEL_USERNAME
# 管理密码: PANEL_PASSWORD

function Fake_Systemctl()
{
    if [[ "$2" = "1panel" ]] || [[ "$2" = "1panel.service" ]]; then
        if [[ "$1" = "stop" ]]; then
            pkill -9 1panel
        elif [[ "$1" = "start" ]]; then
            pkill -0 1panel
            if [[ $? -ne 0 ]]; then
                /usr/bin/1panel > /tmp/1panel.log 2>&1 &
            fi
        elif [[ "$1" = "status" ]]; then
            pkill -0 1panel
            if [[ $? -ne 0 ]]; then
                echo "Active: inactive (dead)"
                exit 3
            else
                echo "Active: active (running)"
            fi
        fi
    else
        if [[ "$1" = "status" ]]; then
            echo "Active: active (running)"
        fi
    fi
}

# 简单判断是不是首次启动
if [[ ! -e /usr/bin/systemctl ]] || [[ ! -e /usr/bin/reboot ]] || [[ ! -e /usr/sbin/cron ]]; then
    apt-get update
    apt-get install ca-certificates curl gnupg dpkg wget cron -y
    which docker >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list
        apt-get update
        apt-get install docker-ce-cli -y
    fi
    apt-get clean
    rm -rf /var/lib/apt/lists/*
    which docker-compose >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi

    rm -rf /usr/bin/systemctl
    cat > /usr/bin/systemctl <<EOL
#!/bin/bash

bash "$0" \$*
EOL
    chmod +x /usr/bin/systemctl

    rm -rf /usr/bin/reboot
    cat > /usr/bin/reboot <<EOL
#!/bin/bash

echo -n "Reboot is not supported, restart 1panel ... "
bash "$0" restart 1panel
if [[ \$? -ne 0 ]]; then
    echo "failed"
    exit 1
fi
echo "ok"
EOL
    chmod +x /usr/bin/reboot

    cd /tmp/
    cat > /tmp/install.sh <<EOL
#!/bin/bash

rm -rf /tmp/1panel-*.tar.gz
cd /tmp/1panel-*
sed -i '1 a function read()\n{\n    return 0\n}\n' install.sh
bash install.sh
EOL
    chmod +x /tmp/install.sh
    if [[ -z "$PANEL_BASE_DIR" ]]; then
        export PANEL_BASE_DIR=/opt
    fi
    # 1Panel 官方安装命令
    # 来源：https://1panel.cn/docs/installation/online_installation/
    curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o /tmp/quick_start.sh
    sed -i 's/install\.sh/\/tmp\/install.sh/' /tmp/quick_start.sh
    bash /tmp/quick_start.sh
    rm -rf /tmp/install.sh
    rm -rf /tmp/1panel-*
fi

if [[ ! -z "$1" ]]; then
    if [[ "$1" = "restart" ]] || [[ "$1" = "reload" ]];then
        Fake_Systemctl stop $2
        Fake_Systemctl start $2
    else
        Fake_Systemctl $1 $2
    fi
    exit 0
fi

if [[ -e "/var/run/crond.pid" ]]; then
    kill -0 $(cat /var/run/crond.pid) > /dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        rm -rf /var/run/crond.pid
    fi
fi
if [[ ! -e "/var/run/crond.pid" ]]; then
    /usr/sbin/cron
fi

Fake_Systemctl start 1panel

exec "/bin/bash"
