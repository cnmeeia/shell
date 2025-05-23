#!/bin/bash

set -euo pipefail

# SSH 配置文件路径
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP_CONFIG="${SSHD_CONFIG}.bak.$(date +%F_%T)"

# SSH key 相关路径
SSH_DIR="/root/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

# 要添加的 SSH 公钥（你可以替换为自己的）
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdB0oklHGLCKQmX0j+vgAWGuS/lQeMJ5w1Y329u1g9Bj+M50FZV9QPwigtsrdr1HuDyV6//FScxD4wtJoFNkzQJx7rg0K4CsJqelIRvlc2za9gEax+BIbqgRXYbm8sOlyGqSr3HOu+pMV2AAnylTqFFE0kkPtouxyE5cnxrvJjSnyowr59JJGnh4ZfghzjCYWkjU9u2WmExNJ1zQUchgVDkAvRWQjbZub50V976zV1e71z9dScx89F1QrW+DfaTBFXUbJmPGri1xFEf3UCS8dPeYhxOHTMJpH1Nh/segsCgahdy49j13LbM1dJKVbI0DzdlmSkEC7XrDJXPOLGdEXEIhAniaFtRgiL2VwdVWxJVkHGIHgqEOV9GN2x/FzrgRiVbnZV8TfVIg8TmI3om+rTKvytuOwErWLP7+wYZ/Q5cmn9+QZDDEtCxujDmS6tAFjRsrkIg3kEIRb0ehVyj/JoTY0UTGdxNC26hLDuEb5BukdPkMA4kufQLQzOWMucWE3yfM14/CYbh3RBMU/CFqObc5eWzGuq2dotnjJh22c8GhSnvbt7vyXFMtj+mWKz2UcB4QMZr3pO0+hpkbP9mqHRCgMGsoQXTJAe68ch4WPn3N575brn0YXHyCBACBxPaL2x8p4FLjx9xLwFKecbkiQD0uR8m4bqpzm2SRuq127U0w=="

# 配置项列表
declare -A CONFIGS=(
    ["AuthorizedKeysFile"]=".ssh/authorized_keys"
    ["ClientAliveInterval"]="60"
    ["ClientAliveCountMax"]="3"
    ["PasswordAuthentication"]="no"
    ["PermitRootLogin"]="yes"
    ["PubkeyAuthentication"]="yes"
)

echo "📁 备份 SSH 配置文件为 $BACKUP_CONFIG..."
cp "$SSHD_CONFIG" "$BACKUP_CONFIG"

echo "🔧 正在修改 SSH 配置项..."
for KEY in "${!CONFIGS[@]}"; do
    VALUE="${CONFIGS[$KEY]}"
    if grep -qE "^\s*${KEY}\b" "$SSHD_CONFIG"; then
        sed -i "s|^\s*${KEY}\b.*|${KEY} ${VALUE}|" "$SSHD_CONFIG"
    else
        echo "${KEY} ${VALUE}" >> "$SSHD_CONFIG"
    fi
done

echo "📂 检查 .ssh 目录..."
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

echo "🔑 设置 authorized_keys..."
touch "$AUTHORIZED_KEYS"
chmod 600 "$AUTHORIZED_KEYS"
if ! grep -qF "$SSH_KEY" "$AUTHORIZED_KEYS"; then
    echo "$SSH_KEY" >> "$AUTHORIZED_KEYS"
    echo "✅ SSH 公钥已添加。"
else
    echo "ℹ️ SSH 公钥已存在，跳过。"
fi

echo "🧪 验证 SSH 配置语法..."
if sshd -t; then
    echo "✅ SSH 配置语法正确。重启 sshd..."
    systemctl restart sshd && echo "✅ sshd 重启成功。" || echo "❌ sshd 重启失败，请检查。"
else
    echo "❌ SSH 配置语法有误，请手动检查 $SSHD_CONFIG。"
    exit 1
fi

echo "🎉 配置完成，准备重启系统..."
sleep 2
reboot
