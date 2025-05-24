#!/bin/bash

# =========================================================================
# ClashX 代理配置脚本 (Ubuntu 服务器作为客户端)
#
# 该脚本用于配置 Ubuntu 服务器上的 containerd、Docker Daemon 和系统环境变量，
# 使其通过 Mac 电脑上的 ClashX 代理进行网络访问。
# =========================================================================

# --- 用户可配置参数 ---
# 您的 Mac 电脑在局域网内的 IP 地址，例如 192.168.1.16
YOUR_MAC_LAN_IP="192.168.1.16" # <--- 请务必修改为您的 Mac 实际 IP！

# ClashX 的混合代理端口 (mixed-port)，通常为 7890
CLASHX_PORT="7890"

# 不需要走代理的 IP/域名列表，多个用逗号分隔
# 常见：localhost,127.0.0.1,::1 (本地回环), *.local (本地网络域名)
# 如果是 Kubernetes 集群，可能需要添加 *.svc,*.cluster.local
NO_PROXY_LIST="localhost,127.0.0.1,::1,*.local"

# --- 内部变量 (通常无需修改) ---
PROXY_HTTP="http://${YOUR_MAC_LAN_IP}:${CLASHX_PORT}"
PROXY_HTTPS="http://${YOUR_MAC_LAN_IP}:${CLASHX_PORT}" # HTTPS 流量也走 HTTP 代理
PROXY_SOCKS="socks5://${YOUR_MAC_LAN_IP}:${CLASHX_PORT}"
ENV_FILE_PATH="/etc/profile.d/proxy.sh"
CONTAINERD_PROXY_CONF_DIR="/etc/systemd/system/containerd.service.d"
DOCKER_PROXY_CONF_DIR="/etc/systemd/system/docker.service.d"
CONTAINERD_PROXY_CONF_FILE="${CONTAINERD_PROXY_CONF_DIR}/http-proxy.conf"
DOCKER_PROXY_CONF_FILE="${DOCKER_PROXY_CONF_DIR}/http-proxy.conf"

# --- 函数定义 ---

# 检查是否为 root 用户
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "此脚本需要 root 权限运行。请使用 sudo。"
        exit 1
    fi
}

# 启用代理配置
enable_proxy() {
    echo "--- 正在启用代理配置 ---"

    # 1. 配置 containerd 代理
    echo "配置 containerd 代理..."
    mkdir -p "${CONTAINERD_PROXY_CONF_DIR}"
    cat <<EOF > "${CONTAINERD_PROXY_CONF_FILE}"
[Service]
Environment="HTTP_PROXY=${PROXY_HTTP}"
Environment="HTTPS_PROXY=${PROXY_HTTPS}"
Environment="NO_PROXY=${NO_PROXY_LIST}"
EOF
    if [ $? -eq 0 ]; then
        echo "containerd 代理配置已写入：${CONTAINERD_PROXY_CONF_FILE}"
    else
        echo "错误：无法写入 containerd 代理配置！"
        return 1
    fi

    # 2. 配置 Docker Daemon 代理 (如果已安装)
    if systemctl is-active --quiet docker; then
        echo "配置 Docker Daemon 代理..."
        mkdir -p "${DOCKER_PROXY_CONF_DIR}"
        cat <<EOF > "${DOCKER_PROXY_CONF_FILE}"
[Service]
Environment="HTTP_PROXY=${PROXY_HTTP}"
Environment="HTTPS_PROXY=${PROXY_HTTPS}"
Environment="NO_PROXY=${NO_PROXY_LIST}"
EOF
        if [ $? -eq 0 ]; then
            echo "Docker Daemon 代理配置已写入：${DOCKER_PROXY_CONF_FILE}"
        else
            echo "错误：无法写入 Docker Daemon 代理配置！"
            return 1
        fi
    else
        echo "Docker Daemon 未运行或未安装，跳过 Docker Daemon 代理配置。"
    fi

    # 3. 配置系统范围的环境变量
    echo "配置系统范围的环境变量..."
    cat <<EOF > "${ENV_FILE_PATH}"
export HTTP_PROXY="${PROXY_HTTP}"
export HTTPS_PROXY="${PROXY_HTTPS}"
export SOCKS_PROXY="${PROXY_SOCKS}"
export ALL_PROXY="${PROXY_SOCKS}"
export NO_PROXY="${NO_PROXY_LIST}"
EOF
    chmod +x "${ENV_FILE_PATH}"
    if [ $? -eq 0 ]; then
        echo "系统环境变量配置已写入：${ENV_FILE_PATH}"
        echo "注意：对于新的 shell 会话，环境变量会自动加载。对于当前会话，请运行 'source ${ENV_FILE_PATH}'。"
    else
        echo "错误：无法写入系统环境变量配置！"
        return 1
    fi

    # 4. 重新加载 systemd 并重启服务
    echo "重新加载 systemd 配置..."
    systemctl daemon-reload
    if [ $? -ne 0 ]; then
        echo "错误：systemctl daemon-reload 失败！"
        return 1
    fi

    echo "重启 containerd 服务..."
    systemctl restart containerd
    if [ $? -ne 0 ]; then
        echo "错误：重启 containerd 失败！"
        return 1
    fi
    systemctl status containerd --no-pager | head -n 3 # 显示状态

    if systemctl is-active --quiet docker; then
        echo "重启 Docker Daemon 服务..."
        systemctl restart docker
        if [ $? -ne 0 ]; then
            echo "错误：重启 Docker Daemon 失败！"
            return 1
        fi
        systemctl status docker --no-pager | head -n 3 # 显示状态
    fi

    echo "--- 代理配置已成功启用！ ---"
    echo "请尝试拉取 Docker 镜像：sudo crictl pull docker.io/alpine:latest"
    echo "请尝试 curl 测试：curl ifconfig.me"
    echo "如果 curl 依然显示本地 IP，请在当前会话中运行 'source ${ENV_FILE_PATH}'。"
    echo "同时，请在 Mac 上的 ClashX Dashboard 观察流量是否通过。"
}

# 禁用代理配置
disable_proxy() {
    echo "--- 正在禁用代理配置 ---"

    # 1. 移除 containerd 代理配置
    echo "移除 containerd 代理配置..."
    if [ -f "${CONTAINERD_PROXY_CONF_FILE}" ]; then
        rm "${CONTAINERD_PROXY_CONF_FILE}"
        echo "已移除 ${CONTAINERD_PROXY_CONF_FILE}"
    else
        echo "${CONTAINERD_PROXY_CONF_FILE} 不存在，无需移除。"
    fi

    # 2. 移除 Docker Daemon 代理配置
    echo "移除 Docker Daemon 代理配置..."
    if [ -f "${DOCKER_PROXY_CONF_FILE}" ]; then
        rm "${DOCKER_PROXY_CONF_FILE}"
        echo "已移除 ${DOCKER_PROXY_CONF_FILE}"
    else
        echo "${DOCKER_PROXY_CONF_FILE} 不存在，无需移除。"
    fi

    # 3. 移除系统范围的环境变量
    echo "移除系统环境变量配置..."
    if [ -f "${ENV_FILE_PATH}" ]; then
        rm "${ENV_FILE_PATH}"
        echo "已移除 ${ENV_FILE_PATH}"
        echo "注意：对于当前 shell 会话，环境变量可能仍然存在，请关闭并重新打开终端会话。"
    else
        echo "${ENV_FILE_PATH} 不存在，无需移除。"
    fi

    # 4. 重新加载 systemd 并重启服务
    echo "重新加载 systemd 配置..."
    systemctl daemon-reload
    if [ $? -ne 0 ]; then
        echo "错误：systemctl daemon-reload 失败！"
        return 1
    fi

    echo "重启 containerd 服务..."
    systemctl restart containerd
    if [ $? -ne 0 ]; then
        echo "错误：重启 containerd 失败！"
        return 1
    fi
    systemctl status containerd --no-pager | head -n 3

    if systemctl is-active --quiet docker; then
        echo "重启 Docker Daemon 服务..."
        systemctl restart docker
        if [ $? -ne 0 ]; then
            echo "错误：重启 Docker Daemon 失败！"
            return 1
        fi
        systemctl status docker --no-pager | head -n 3
    fi

    echo "--- 代理配置已成功禁用！ ---"
}

# --- 主逻辑 ---
check_root

case "$1" in
    enable)
        echo "您确定要启用代理配置吗？ (y/N)"
        read -r CONFIRM
        if [[ "$CONFIRM" =~ ^[yY]$ ]]; then
            enable_proxy
        else
            echo "操作已取消。"
        fi
        ;;
    disable)
        echo "您确定要禁用代理配置吗？ (y/N)"
        read -r CONFIRM
        if [[ "$CONFIRM" =~ ^[yY]$ ]]; then
            disable_proxy
        else
            echo "操作已取消。"
        fi
        ;;
    *)
        echo "用法: sudo $0 [enable|disable]"
        echo "  enable  - 启用代理配置"
        echo "  disable - 禁用代理配置"
        echo ""
        echo "当前配置的 Mac IP: ${YOUR_MAC_LAN_IP}"
        echo "当前配置的 ClashX 端口: ${CLASHX_PORT}"
        echo "请修改脚本顶部的 YOUR_MAC_LAN_IP 和 CLASHX_PORT 变量以适应您的环境。"
        ;;
esac
