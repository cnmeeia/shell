#!/bin/bash

# 默认 Swap 文件大小（单位：MB）
DEFAULT_SWAP_SIZE_MB=2048
SWAP_FILE="/swapfile"

# 如果提供了参数，则使用用户指定的大小，否则使用默认值
SWAP_SIZE_MB=${1:-$DEFAULT_SWAP_SIZE_MB}

# 检查是否以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "请以 root 权限运行此脚本。"
    exit 1
fi

echo "开始创建 ${SWAP_SIZE_MB}MB 的 Swap 文件..."

# 创建 Swap 文件
dd if=/dev/zero of="$SWAP_FILE" bs=1M count="$SWAP_SIZE_MB" status=progress
if [ $? -ne 0 ]; then
    echo "创建 Swap 文件失败，请检查磁盘空间或权限。"
    exit 1
fi

# 设置权限
echo "设置 Swap 文件权限为 600..."
chmod 600 "$SWAP_FILE"

# 格式化 Swap 文件
echo "格式化 Swap 文件..."
mkswap "$SWAP_FILE"
if [ $? -ne 0 ]; then
    echo "格式化 Swap 文件失败。"
    exit 1
fi

# 激活 Swap 文件
echo "激活 Swap 文件..."
swapon "$SWAP_FILE"
if [ $? -ne 0 ]; then
    echo "激活 Swap 文件失败。"
    exit 1
fi

# 验证 Swap 是否生效
echo "当前内存信息："
free -m

# 配置开机自动挂载
echo "配置开机自动挂载..."
if ! grep -q "$SWAP_FILE" /etc/fstab; then
    echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
    echo "已添加开机自动挂载配置到 /etc/fstab。"
else
    echo "/etc/fstab 已包含 Swap 文件配置，无需重复添加。"
fi

echo "Swap 文件配置完成！"