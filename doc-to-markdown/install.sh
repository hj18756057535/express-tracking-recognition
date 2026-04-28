#!/bin/bash
# MinerU 安装脚本 - Linux/macOS 版本（支持 pyenv 和 vfox）
# 作者: AI Assistant
# 版本: 2.0

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# 检测操作系统
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    else
        OS="unknown"
    fi
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ==========================================
# 步骤 1: 检查并安装 pyenv
# ==========================================
check_and_install_pyenv() {
    print_header "步骤 1/6: 检查 Python 环境管理器"
    
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
    print_info "正在安装 pyenv..."
    echo ""
    
    if [[ "$OS" == "macos" ]]; then
        # macOS 使用 Homebrew
        if command_exists brew; then
            print_info "使用 Homebrew 安装 pyenv..."
            brew install pyenv
        else
            print_error "未检测到 Homebrew"
            print_info "请先安装 Homebrew: https://brew.sh"
            exit 1
        fi
    else
        # Linux 使用官方安装脚本
        print_info "使用官方脚本安装 pyenv..."
        
        # 安装依赖
        if [[ "$DISTRO" == "ubuntu" ]] || [[ "$DISTRO" == "debian" ]]; then
            print_info "安装依赖包..."
            sudo apt-get update
            sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
                libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
                libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
                libffi-dev liblzma-dev
        elif [[ "$DISTRO" == "fedora" ]] || [[ "$DISTRO" == "rhel" ]] || [[ "$DISTRO" == "centos" ]]; then
            print_info "安装依赖包..."
            sudo dnf install -y make gcc zlib-devel bzip2 bzip2-devel \
                readline-devel sqlite sqlite-devel openssl-devel tk-devel \
                libffi-devel xz-devel
        fi
        
        # 安装 pyenv
        curl https://pyenv.run | bash
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
    print_header "步骤 2/6: 检查 Python 环境"
    
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
    echo ""
    
    # 安装 Python
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
# 步骤 3: 升级 pip
# ==========================================
upgrade_pip() {
    print_header "步骤 3/6: 升级 pip"
    
    $PYTHON_CMD -m pip install --upgrade pip
    
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
    print_header "步骤 4/6: 安装 uv 包管理器"
    
    $PYTHON_CMD -m pip install uv
    
    if [ $? -eq 0 ]; then
        print_success "uv 安装成功"
    else
        print_error "uv 安装失败"
        exit 1
    fi
}

# ==========================================
# 步骤 5: 安装 MarkItDown
# ==========================================
install_markitdown() {
    print_header "步骤 5/7: 安装 MarkItDown"
    
    print_info "安装 MarkItDown（Word 转换引擎）..."
    echo ""
    
    $PYTHON_CMD -m pip install markitdown
    
    if [ $? -eq 0 ]; then
        print_success "MarkItDown 安装成功"
    else
        print_warning "MarkItDown 安装失败，但可以继续使用 MinerU"
    fi
}

# ==========================================
# 步骤 6: 安装 MinerU
# ==========================================
install_mineru() {
    print_header "步骤 6/7: 安装 MinerU 3.0"
    
    print_info "安装 MinerU（PDF 转换引擎）..."
    print_info "这可能需要几分钟时间，请耐心等待..."
    echo ""
    
    $PYTHON_CMD -m uv pip install -U "mineru[all]"
    
    if [ $? -eq 0 ]; then
        print_success "MinerU 安装成功"
    else
        print_error "MinerU 安装失败"
        echo ""
        print_info "故障排除:"
        echo "  1. 清理缓存: pip cache purge"
        echo "  2. 使用国内镜像: pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple"
        echo "  3. 重新运行此脚本"
        exit 1
    fi
}

# ==========================================
# 步骤 7: 验证安装
# ==========================================
verify_installation() {
    print_header "步骤 7/7: 验证安装"
    
    # 检查 MarkItDown
    if $PYTHON_CMD -m markitdown --version >/dev/null 2>&1; then
        print_success "MarkItDown 安装成功"
        $PYTHON_CMD -m markitdown --version
    else
        print_warning "MarkItDown 未安装（Word 转换不可用）"
    fi
    
    echo ""
    
    # 检查 MinerU
    if command_exists mineru; then
        print_success "MinerU 命令可用"
        mineru --version
    else
        print_warning "MinerU 命令未找到"
        print_info "可能需要重启终端或运行: source ~/.bashrc"
        echo ""
        print_info "或尝试: $PYTHON_CMD -m magic_pdf --version"
    fi
}

# ==========================================
# 可选: 安装 vfox 和 Node.js
# ==========================================
install_vfox_optional() {
    echo ""
    print_info "检测到可选组件: vfox (Node.js 版本管理器)"
    read -p "是否安装 vfox 和 Node.js？(可选) [y/N]: " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_vfox
    else
        print_info "跳过 vfox 安装"
    fi
}

install_vfox() {
    print_header "安装 vfox"
    
    if command_exists vfox; then
        print_success "vfox 已安装"
        vfox --version
        return 0
    fi
    
    if [[ "$OS" == "macos" ]]; then
        if command_exists brew; then
            print_info "使用 Homebrew 安装 vfox..."
            brew install vfox
        fi
    else
        print_info "使用官方脚本安装 vfox..."
        curl -sSL https://raw.githubusercontent.com/version-fox/vfox/main/install.sh | bash
    fi
    
    # 配置 shell
    local shell_config=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_config="$HOME/.zshrc"
        echo 'eval "$(vfox activate zsh)"' >> "$shell_config"
    else
        shell_config="$HOME/.bashrc"
        echo 'eval "$(vfox activate bash)"' >> "$shell_config"
    fi
    
    # 立即激活
    eval "$(vfox activate bash)" 2>/dev/null || eval "$(vfox activate zsh)" 2>/dev/null
    
    print_success "vfox 安装成功"
    
    # 安装 Node.js
    print_info "安装 Node.js LTS..."
    vfox add nodejs
    vfox install nodejs@lts
    vfox use nodejs@lts
    
    print_success "Node.js 安装成功"
    node --version
}

# ==========================================
# 打印安装总结
# ==========================================
print_summary() {
    echo ""
    print_header "安装完成！"
    
    echo -e "${GREEN}📋 环境信息:${NC}"
    echo "  操作系统: $OS"
    if command_exists pyenv; then
        echo "  pyenv: $(pyenv --version)"
    fi
    echo "  Python: $($PYTHON_CMD --version)"
    if $PYTHON_CMD -m markitdown --version >/dev/null 2>&1; then
        echo "  MarkItDown (Word): $($PYTHON_CMD -m markitdown --version)"
    else
        echo "  MarkItDown (Word): 未安装"
    fi
    if command_exists mineru; then
        echo "  MinerU (PDF): $(mineru --version)"
    else
        echo "  MinerU (PDF): 未安装"
    fi
    if command_exists vfox; then
        echo "  vfox: $(vfox --version)"
    fi
    if command_exists node; then
        echo "  Node.js: $(node --version)"
    fi
    
    echo ""
    echo -e "${BLUE}📖 使用方法:${NC}"
    echo "  Word 转换:  python -m markitdown input.docx > output.md"
    echo "  PDF 转换:   mineru -p input.pdf -o output/ -b pipeline"
    echo "  批量转换:   mineru -p docs/ -o output/ -b pipeline"
    
    echo ""
    echo -e "${BLUE}💡 在 Kiro 中使用:${NC}"
    echo "  直接说: \"转换 docs/ai/xxx.pdf\" 或 \"转换 docs/ai/xxx.docx\""
    echo "  系统会自动选择合适的引擎"
    
    echo ""
    echo -e "${BLUE}📚 更多帮助:${NC}"
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
    print_header "MinerU + MarkItDown 安装脚本 (Linux/macOS)"
    print_info "MinerU (PDF) + MarkItDown (Word)"
    echo ""
    
    # 检测操作系统
    detect_os
    print_info "检测到操作系统: $OS"
    echo ""
    
    # 执行安装步骤
    check_and_install_pyenv
    check_and_install_python
    upgrade_pip
    install_uv
    install_markitdown
    install_mineru
    verify_installation
    
    # 可选安装
    install_vfox_optional
    
    # 打印总结
    print_summary
}

# 运行主函数
main
