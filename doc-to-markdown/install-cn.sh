#!/bin/bash
# ==========================================
# 文档转 Markdown 安装脚本 - 国内网络适配版 (macOS)
# 基于原始 install.sh，针对中国大陆网络环境优化
#
# 优化项:
#   1. pip/uv 使用清华大学镜像源
#   2. Homebrew 使用中科大镜像源
#   3. pyenv 使用 npmmirror Python 镜像
#   4. pyenv 官方安装脚本使用 GitHub 代理
#   5. 完善的错误处理和重试机制
#
# ⚠️ 关键说明:
#   macOS 上的 pyenv 是从源码编译 Python，下载的是 Python 源码 tarball
#   设置 PYTHON_BUILD_MIRROR_URL 环境变量即可让 pyenv 从国内镜像下载源码
#   这与 Windows 上 pyenv-win（下载 exe 安装包）的机制不同
# ==========================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ==========================================
# 国内镜像源配置
# ==========================================
PIP_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple"
UV_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple"
PYENV_MIRROR="https://npmmirror.com/mirrors/python"
HOMEBREW_MIRROR="https://mirrors.ustc.edu.cn/homebrew-bottles"

# 打印函数
print_header() {
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ==========================================
# 步骤 0: 配置国内镜像环境
# ==========================================
configure_china_mirrors() {
    print_header "步骤 0/7: 配置国内镜像源"

    echo "镜像源配置:"
    echo "  pip:     $PIP_MIRROR"
    echo "  uv:      $UV_MIRROR"
    echo "  pyenv:   $PYENV_MIRROR"
    echo "  Homebrew: $HOMEBREW_MIRROR"
    echo ""

    # 设置 pyenv 镜像（当前会话生效）
    export PYTHON_BUILD_MIRROR_URL="$PYENV_MIRROR"
    print_info "已设置 PYTHON_BUILD_MIRROR_URL=$PYENV_MIRROR"

    # 写入 shell 配置文件（永久生效）
    local shell_config=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zshrc"
    else
        shell_config="$HOME/.bashrc"
    fi

    if ! grep -q "PYTHON_BUILD_MIRROR_URL" "$shell_config" 2>/dev/null; then
        echo "" >> "$shell_config"
        echo "# pyenv 国内镜像（文档转 Markdown 工具链）" >> "$shell_config"
        echo "export PYTHON_BUILD_MIRROR_URL=\"$PYENV_MIRROR\"" >> "$shell_config"
        print_info "已将 PYTHON_BUILD_MIRROR_URL 写入 $shell_config"
    else
        print_info "PYTHON_BUILD_MIRROR_URL 已在 $shell_config 中配置"
    fi

    # 配置 Homebrew 镜像（如果已安装）
    if command_exists brew; then
        if [ -z "$HOMEBREW_BOTTLE_DOMAIN" ]; then
            export HOMEBREW_BOTTLE_DOMAIN="$HOMEBREW_MIRROR"
            if ! grep -q "HOMEBREW_BOTTLE_DOMAIN" "$shell_config" 2>/dev/null; then
                echo "export HOMEBREW_BOTTLE_DOMAIN=\"$HOMEBREW_MIRROR\"" >> "$shell_config"
                print_info "已配置 Homebrew 国内镜像"
            fi
        else
            print_info "Homebrew 镜像已配置: $HOMEBREW_BOTTLE_DOMAIN"
        fi
    fi

    print_success "国内镜像源配置完成"
}

# ==========================================
# 步骤 1: 检查并安装 pyenv
# ==========================================
check_and_install_pyenv() {
    print_header "步骤 1/7: 检查 Python 环境管理器"

    if command_exists pyenv; then
        print_success "pyenv 已安装"
        pyenv --version
        return 0
    fi

    print_warning "未检测到 pyenv"
    echo ""
    read -p "是否安装 pyenv？(推荐) [Y/n]: " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        install_pyenv
    else
        print_info "跳过 pyenv 安装，将使用系统 Python"
    fi
}

install_pyenv() {
    print_info "正在安装 pyenv（使用国内代理）..."
    echo ""

    # macOS 使用 Homebrew
    if command_exists brew; then
        print_info "使用 Homebrew 安装 pyenv..."
        brew install pyenv
    else
        print_warning "未检测到 Homebrew"
        echo ""
        read -p "是否安装 Homebrew？(推荐) [Y/n]: " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            # 使用国内镜像安装 Homebrew
            print_info "使用国内镜像安装 Homebrew..."
            /bin/bash -c "$(curl -fsSL https://ghp.ci/https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            brew install pyenv
        else
            # 使用 pyenv 官方安装脚本（GitHub 代理）
            print_info "使用官方脚本安装 pyenv（国内代理）..."
            curl -fsSL https://ghp.ci/https://pyenv.run | bash
        fi
    fi

    # 添加到 shell 配置
    setup_pyenv_shell

    print_success "pyenv 安装成功！"
    print_warning "请运行以下命令重新加载配置，或重启终端："
    echo ""
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "  source ~/.zshrc"
    else
        echo "  source ~/.bashrc"
    fi
    echo ""
    read -p "按 Enter 继续..."
}

setup_pyenv_shell() {
    local shell_config=""

    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zshrc"
    else
        shell_config="$HOME/.bashrc"
    fi

    # 检查是否已配置
    if grep -q "pyenv init" "$shell_config" 2>/dev/null; then
        print_info "pyenv 已在 $shell_config 中配置"
        return 0
    fi

    print_info "配置 pyenv 到 $shell_config..."

    cat >> "$shell_config" << 'EOF'

# pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF

    # 立即加载配置
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
}

# ==========================================
# 步骤 2: 检查并安装 Python
# ==========================================
check_and_install_python() {
    print_header "步骤 2/7: 检查 Python 环境"

    if command_exists python3; then
        PYTHON_CMD="python3"
    elif command_exists python; then
        PYTHON_CMD="python"
    else
        PYTHON_CMD=""
    fi

    if [ -n "$PYTHON_CMD" ]; then
        print_success "Python 已安装"
        $PYTHON_CMD --version

        # 检查版本
        PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | awk '{print $2}')
        MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
        MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)

        if [ "$MAJOR" -eq 3 ] && [ "$MINOR" -ge 10 ] && [ "$MINOR" -le 13 ]; then
            print_success "Python 版本符合要求 (3.10-3.13)"
            return 0
        else
            print_warning "Python 版本 $PYTHON_VERSION 可能不兼容（需要 3.10-3.13）"
            echo ""
            read -p "是否使用 pyenv 安装推荐版本 3.11.9？[Y/n]: " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                install_python_with_pyenv
            fi
        fi
    else
        print_warning "未检测到 Python"

        if command_exists pyenv; then
            install_python_with_pyenv
        else
            print_error "请先安装 Python 3.10-3.13"
            exit 1
        fi
    fi
}

install_python_with_pyenv() {
    print_info "使用 pyenv 安装 Python 3.11.9（推荐版本）..."
    print_info "下载源: $PYTHON_BUILD_MIRROR_URL (国内镜像)"
    echo ""

    # macOS 可能需要安装编译依赖
    if command_exists brew; then
        print_info "检查 Python 编译依赖..."
        brew install -q openssl readline sqlite3 xz zlib tcl-tk 2>/dev/null || true
    fi

    # 安装 Python（已通过 PYTHON_BUILD_MIRROR_URL 指定国内镜像）
    pyenv install 3.11.9

    # 设置全局版本
    print_info "设置 Python 3.11.9 为全局版本..."
    pyenv global 3.11.9
    pyenv rehash

    # 更新命令
    PYTHON_CMD="python"

    print_success "Python 3.11.9 安装成功！"
    $PYTHON_CMD --version
}

# ==========================================
# 步骤 3: 配置 pip 国内镜像并升级
# ==========================================
configure_pip_mirror_and_upgrade() {
    print_header "步骤 3/7: 配置 pip 国内镜像源并升级"

    print_info "正在配置 pip 使用清华大学镜像源..."
    $PYTHON_CMD -m pip config set global.index-url "$PIP_MIRROR"
    $PYTHON_CMD -m pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn

    print_success "pip 镜像源已配置为: $PIP_MIRROR"
    echo ""

    print_info "正在升级 pip..."
    $PYTHON_CMD -m pip install --upgrade pip -i "$PIP_MIRROR" --trusted-host pypi.tuna.tsinghua.edu.cn

    if [ $? -eq 0 ]; then
        print_success "pip 升级成功"
    else
        print_warning "pip 升级失败，尝试继续..."
    fi
}

# ==========================================
# 步骤 4: 安装 uv
# ==========================================
install_uv() {
    print_header "步骤 4/7: 安装 uv 包管理器（国内镜像加速）"

    $PYTHON_CMD -m pip install uv -i "$PIP_MIRROR" --trusted-host pypi.tuna.tsinghua.edu.cn

    if [ $? -eq 0 ]; then
        print_success "uv 安装成功"
    else
        print_warning "pip 安装 uv 失败，尝试使用官方安装脚本..."
        curl -LsSf https://ghp.ci/https://astral.sh/uv/install.sh | sh
        if [ $? -ne 0 ]; then
            print_error "uv 安装失败"
            exit 1
        fi
        print_success "uv 安装成功"
    fi
}

# ==========================================
# 步骤 5: 安装 MarkItDown
# ==========================================
install_markitdown() {
    print_header "步骤 5/7: 安装 MarkItDown（国内镜像加速）"

    print_info "安装 MarkItDown（Word 转换引擎）..."
    echo ""

    $PYTHON_CMD -m pip install markitdown -i "$PIP_MIRROR" --trusted-host pypi.tuna.tsinghua.edu.cn

    if [ $? -eq 0 ]; then
        print_success "MarkItDown 安装成功"
    else
        print_warning "MarkItDown 安装失败，尝试不带 trusted-host..."
        $PYTHON_CMD -m pip install markitdown -i "$PIP_MIRROR"
        if [ $? -ne 0 ]; then
            print_warning "MarkItDown 安装失败，但可以继续使用 MinerU"
        fi
    fi
}

# ==========================================
# 步骤 6: 安装 MinerU
# ==========================================
install_mineru() {
    print_header "步骤 6/7: 安装 MinerU 3.0（国内镜像加速）"

    print_info "安装 MinerU（PDF 转换引擎）..."
    print_info "这可能需要几分钟时间，请耐心等待..."
    print_warning "首次运行 MinerU 时需要下载模型文件（约 810MB）"
    echo ""

    $PYTHON_CMD -m uv pip install -U "mineru[all]" --index-url "$UV_MIRROR" --trusted-host pypi.tuna.tsinghua.edu.cn

    if [ $? -eq 0 ]; then
        print_success "MinerU 安装成功"
    else
        print_warning "uv 安装 MinerU 失败，尝试使用 pip..."
        $PYTHON_CMD -m pip install "mineru[all]" -i "$PIP_MIRROR" --trusted-host pypi.tuna.tsinghua.edu.cn

        if [ $? -ne 0 ]; then
            print_error "MinerU 安装失败"
            echo ""
            print_info "故障排除:"
            echo "  1. 清理缓存: pip cache purge"
            echo "  2. 检查网络: ping pypi.tuna.tsinghua.edu.cn"
            echo "  3. 重新运行此脚本"
            echo "  4. 仅安装 MarkItDown: pip install markitdown"
            exit 1
        fi
        print_success "MinerU 安装成功"
    fi
}

# ==========================================
# 步骤 7: 验证安装
# ==========================================
verify_installation() {
    print_header "步骤 7/7: 验证安装"

    # 刷新 pyenv shims
    if command_exists pyenv; then
        pyenv rehash 2>/dev/null || true
    fi

    echo "-------------------------------------------"
    echo "  安装验证报告"
    echo "-------------------------------------------"
    echo ""

    # 检查 Python
    echo "[Python]"
    if $PYTHON_CMD --version >/dev/null 2>&1; then
        print_success "Python 正常"
        $PYTHON_CMD --version
    else
        print_error "Python 不可用 - 可能需要重启终端"
    fi
    echo ""

    # 检查 pip
    echo "[pip]"
    if $PYTHON_CMD -m pip --version >/dev/null 2>&1; then
        print_success "pip 正常"
        $PYTHON_CMD -m pip --version
    else
        print_error "pip 不可用"
    fi
    echo ""

    # 检查 MarkItDown
    echo "[MarkItDown - Word 转换引擎]"
    if $PYTHON_CMD -m markitdown --version >/dev/null 2>&1; then
        print_success "MarkItDown 安装成功"
        $PYTHON_CMD -m markitdown --version
    else
        print_warning "MarkItDown 未安装（Word 转换不可用）"
    fi
    echo ""

    # 检查 MinerU
    echo "[MinerU - PDF 转换引擎]"
    if command_exists mineru; then
        print_success "MinerU 安装成功"
        mineru --version
    else
        print_warning "MinerU 命令未找到"
        print_info "可能需要重启终端或运行: source ~/.zshrc"
        print_info "或尝试: $PYTHON_CMD -m magic_pdf.cli --version"
    fi
    echo ""

    # 显示镜像配置
    echo "[pip 镜像配置]"
    $PYTHON_CMD -m pip config get global.index-url 2>/dev/null || echo "未配置"
    echo ""
}

# ==========================================
# 打印安装总结
# ==========================================
print_summary() {
    echo ""
    print_header "安装完成！"

    echo -e "${GREEN}环境信息:${NC}"
    echo "  Python:"
    $PYTHON_CMD --version 2>/dev/null || echo "    未安装"
    echo "  MarkItDown (Word 转换):"
    $PYTHON_CMD -m markitdown --version 2>/dev/null || echo "    未安装"
    echo "  MinerU (PDF 转换):"
    mineru --version 2>/dev/null || echo "    未安装"

    echo ""
    echo -e "${BLUE}使用方法:${NC}"
    echo "  Word 转换:  python -m markitdown input.docx > output.md"
    echo "  PDF 转换:   mineru -p input.pdf -o output/ -b pipeline"
    echo "  批量转换:   mineru -p docs/ -o output/ -b pipeline"

    echo ""
    echo -e "${BLUE}国内镜像已配置:${NC}"
    echo "  pip:       $PIP_MIRROR"
    echo "  pyenv:     $PYENV_MIRROR"
    echo "  Homebrew:  $HOMEBREW_MIRROR"

    echo ""
    echo -e "${BLUE}在 IDE 中使用:${NC}"
    echo "  直接说: \"转换 docs/ai/xxx.pdf\" 或 \"转换 docs/ai/xxx.docx\""
    echo "  系统会自动选择合适的引擎"

    echo ""
    echo -e "${BLUE}更多帮助:${NC}"
    echo "  查看文档: cat README.md"
    echo "  命令帮助: mineru --help"
    echo "  命令帮助: python -m markitdown --help"

    echo ""
    print_warning "如果命令未找到，请重启终端或运行:"
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "  source ~/.zshrc"
    else
        echo "  source ~/.bashrc"
    fi
    echo ""
}

# ==========================================
# 主函数
# ==========================================
main() {
    print_header "文档转 Markdown 安装脚本 (国内版 macOS)"
    print_info "MinerU (PDF) + MarkItDown (Word)"
    print_info "国内网络优化"
    echo ""

    # 执行安装步骤
    configure_china_mirrors
    check_and_install_pyenv
    check_and_install_python
    configure_pip_mirror_and_upgrade
    install_uv
    install_markitdown
    install_mineru
    verify_installation

    # 打印总结
    print_summary
}

# 运行主函数
main
