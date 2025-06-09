#!/bin/bash

# --- 配置项 ---
UPLOAD_SERVER_BASE_URL="http://100.127.145.67:13444/" # 你的上传服务器基地址

# --- 函数：显示使用说明 ---
usage() {
    echo "使用方法: $0"
    echo "此脚本用于列出当前目录文件，让用户选择一个文件，然后将其上传到指定服务器。"
    echo "用法示例: ./upload_interactive.sh"
    exit 1
}

# --- 检查是否安装了必要的工具 ---
check_dependencies() {
    if ! command -v curl &> /dev/null; then
        echo "错误: curl 未安装。请先安装 curl (例如: sudo apt install curl 或 sudo yum install curl)。"
        exit 1
    fi
    if ! command -v find &> /dev/null; then
        echo "错误: find 未安装。这是系统基本命令，请检查您的系统环境。"
        exit 1
    fi
}

# --- 主逻辑 ---
main() {
    check_dependencies

    echo "--- 文件上传交互式脚本 ---"
    echo "目标服务器基地址: $UPLOAD_SERVER_BASE_URL"
    echo ""

    # --- 1. 列出当前目录的文件 ---
    echo "正在扫描当前目录文件..."
    FILES=()
    # 使用 find 命令获取当前目录下的文件列表，并进行排序
    # -maxdepth 1: 只在当前目录查找，不进入子目录
    # -type f: 只查找文件
    # -printf "%P\n": 打印文件相对于搜索路径的名称 (不包含 './')
    while IFS= read -r line; do
        FILES+=("$line")
    done < <(find . -maxdepth 1 -type f -printf "%P\n" | sort)

    # 检查是否有文件
    if [ ${#FILES[@]} -eq 0 ]; then
        echo "错误: 当前目录没有找到任何文件可供上传。"
        echo "请确保脚本运行在包含您要上传文件的目录中。"
        exit 1
    fi

    echo ""
    echo "--- 可供上传的文件列表 ---"
    for i in "${!FILES[@]}"; do
        echo "$((i+1)). ${FILES[$i]}"
    done
    echo ""

    # --- 2. 让用户选择文件 ---
    SELECTED_FILE_INDEX=-1
    while true; do
        read -p "请输入您要上传的文件编号 (或输入 'q' 退出): " CHOICE

        if [[ "$CHOICE" == "q" || "$CHOICE" == "Q" ]]; then
            echo "退出文件上传。"
            exit 0
        fi

        # 验证用户输入
        if ! [[ "$CHOICE" =~ ^[0-9]+$ ]]; then
            echo "无效的输入。请输入一个数字编号。"
            continue
        fi

        # 转换为数组索引 (用户输入从1开始，数组从0开始)
        SELECTED_FILE_INDEX=$((CHOICE-1))

        # 检查编号是否在有效范围内
        if [ "$SELECTED_FILE_INDEX" -lt 0 ] || [ "$SELECTED_FILE_INDEX" -ge ${#FILES[@]} ]; then
            echo "无效的编号。请选择列表中存在的编号。"
            continue
        fi
        break # 有效输入，退出循环
    done

    FILE_TO_UPLOAD="${FILES[$SELECTED_FILE_INDEX]}"
    FILE_PATH_FULL="./$FILE_TO_UPLOAD" # 确保是完整路径，尽管这里因为find的%P已经相对了，但加上./更明确

    echo ""
    echo "您选择了文件: '$FILE_TO_UPLOAD'"
    echo "准备上传到: ${UPLOAD_SERVER_BASE_URL}$FILE_TO_UPLOAD"
    echo "开始上传，请等待实时进度信息..."
    echo ""

    # --- 3. 执行 CURL 上传并显示实时进度条 ---
    # -T: 指定要上传的文件
    # --progress-bar: 显示标准进度条 (实时更新)
    # -w "\n": 上传完成后打印一个新行，保持输出整洁
    curl -T "$FILE_PATH_FULL" "${UPLOAD_SERVER_BASE_URL}$FILE_TO_UPLOAD" --progress-bar -w "\n"

    # 检查 CURL 命令的退出状态
    if [ $? -eq 0 ]; then
        echo "文件 '$FILE_TO_UPLOAD' 上传成功！"
    else
        echo "文件 '$FILE_TO_UPLOAD' 上传失败。请检查网络连接、服务器状态或文件权限。"
        echo "如果上传小文件未显示进度条，可能是因为传输速度过快，瞬间完成。"
    fi
}

# --- 执行主函数 ---
main "$@"
