#!/bin/bash

# SSH 配置文件路径
SSHD_CONFIG="/etc/ssh/sshd_config"

# 定义目标目录和文件
SSH_DIR="/root/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# 定义配置项及其值
declare -A CONFIGS=(
    ["AuthorizedKeysFile"]=".ssh/authorized_keys"
    ["ClientAliveInterval"]="60"
    ["ClientAliveCountMax"]="3"
    ["PasswordAuthentication"]="no"
    ["PermitRootLogin"]="yes"
    ["PubkeyAuthentication"]="yes"
)

# 1. 修改或添加 SSH 配置文件中的配置项
echo "开始修改 SSH 配置文件..."
for KEY in "${!CONFIGS[@]}"; do
    VALUE="${CONFIGS[$KEY]}"
    if grep -q "^${KEY}" "$SSHD_CONFIG"; then
        sed -i "s|^${KEY}.*|${KEY} ${VALUE}|" "$SSHD_CONFIG"
    else
        echo "${KEY} ${VALUE}" >> "$SSHD_CONFIG"
    fi
done
echo "SSH 配置文件已更新。"

# 2. 确保 .ssh 目录存在
echo "检查或创建 .ssh 目录..."
if [ ! -d "$SSH_DIR" ]; then
    mkdir -p "$SSH_DIR"
    echo ".ssh 目录已创建。"
else
    echo ".ssh 目录已存在，跳过创建。"
fi

# 3. 创建或更新 authorized_keys 文件
echo "检查或更新 authorized_keys 文件..."
SSH_KEY="ssh-rsa ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdB0oklHGLCKQmX0j+vgAWGuS/lQeMJ5w1Y329u1g9Bj+M50FZV9QPwigtsrdr1HuDyV6//FScxD4wtJoFNkzQJx7rg0K4CsJqelIRvlc2za9gEax+BIbqgRXYbm8sOlyGqSr3HOu+pMV2AAnylTqFFE0kkPtouxyE5cnxrvJjSnyowr59JJGnh4ZfghzjCYWkjU9u2WmExNJ1zQUchgVDkAvRWQjbZub50V976zV1e71z9dScx89F1QrW+DfaTBFXUbJmPGri1xFEf3UCS8dPeYhxOHTMJpH1Nh/segsCgahdy49j13LbM1dJKVbI0DzdlmSkEC7XrDJXPOLGdEXEIhAniaFtRgiL2VwdVWxJVkHGIHgqEOV9GN2x/FzrgRiVbnZV8TfVIg8TmI3om+rTKvytuOwErWLP7+wYZ/Q5cmn9+QZDDEtCxujDmS6tAFjRsrkIg3kEIRb0ehVyj/JoTY0UTGdxNC26hLDuEb5BukdPkMA4kufQLQzOWMucWE3yfM14/CYbh3RBMU/CFqObc5eWzGuq2dotnjJh22c8GhSnvbt7vyXFMtj+mWKz2UcB4QMZr3pO0+hpkbP9mqHRCgMGsoQXTJAe68ch4WPn3N575brn0YXHyCBACBxPaL2x8p4FLjx9xLwFKecbkiQD0uR8m4bqpzm2SRuq127U0w=="
if ! grep -q "$SSH_KEY" "$AUTHORIZED_KEYS" 2>/dev/null; then
    echo "$SSH_KEY" >> "$AUTHORIZED_KEYS"
    echo "SSH 密钥已添加到 authorized_keys。"
else
    echo "SSH 密钥已存在于 authorized_keys 中，跳过添加。"
fi
echo
# 4. 设置正确的权限
chmod 700 "$SSH_DIR"
chmod 600 "$AUTHORIZED_KEYS"
echo "已设置 .ssh 和 authorized_keys 的权限。"

# 5. 验证 SSH 配置文件语法
echo "验证 SSH 配置文件语法..."
if sshd -t; then
    echo "SSHD 配置文件语法正确。"
    # 重新启动 SSH 服务
    systemctl restart sshd
    if [ $? -eq 0 ]; then
        echo "SSHD 服务已成功重启。"
    else
        echo "重启 SSHD 服务失败，请检查日志。"
    fi
else
    echo "SSHD 配置文件存在语法错误，请检查 $SSHD_CONFIG。"
fi
echo
echo "脚本执行完成！"
echo
echo "重启"

reboot
