@echo off
REM MinerU 安装脚本 - Windows 版本（支持 pyenv-win）
REM 作者: AI Assistant
REM 版本: 2.0

setlocal enabledelayedexpansion

echo =========================================
echo   文档转 Markdown 安装脚本 (Windows)
echo   MinerU (PDF) + MarkItDown (Word)
echo =========================================
echo.

REM ==========================================
REM 步骤 1: 检查并安装 pyenv-win
REM ==========================================
echo [步骤 1/5] 检查 Python 环境管理器...
echo.

pyenv --version >nul 2>&1
if errorlevel 1 (
    echo ⚠️  未检测到 pyenv-win
    echo.
    choice /C YN /M "是否安装 pyenv-win（推荐）"
    if errorlevel 2 goto :skip_pyenv
    if errorlevel 1 goto :install_pyenv
) else (
    echo ✅ pyenv-win 已安装
    pyenv --version
    goto :check_python
)

:install_pyenv
echo.
echo 正在安装 pyenv-win...
echo 方法: 使用 PowerShell 脚本
echo.

REM 使用 PowerShell 安装 pyenv-win
powershell -Command "Invoke-WebRequest -UseBasicParsing -Uri 'https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1' -OutFile './install-pyenv-win.ps1'; & './install-pyenv-win.ps1'"

if errorlevel 1 (
    echo ❌ pyenv-win 安装失败
    echo.
    echo 请手动安装:
    echo 1. 访问: https://github.com/pyenv-win/pyenv-win
    echo 2. 或使用 Git: git clone https://github.com/pyenv-win/pyenv-win.git "%USERPROFILE%\.pyenv"
    echo 3. 添加环境变量后重启终端
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ pyenv-win 安装成功！
echo.
echo ⚠️  重要: 请关闭当前终端，重新打开后再次运行此脚本
echo.
pause
exit /b 0

:skip_pyenv
echo.
echo 跳过 pyenv-win 安装，将使用系统 Python
echo.

REM ==========================================
REM 步骤 2: 检查并安装 Python
REM ==========================================
:check_python
echo.
echo [步骤 2/5] 检查 Python 环境...
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ 未检测到 Python
    echo.
    
    REM 检查是否有 pyenv
    pyenv --version >nul 2>&1
    if errorlevel 1 (
        echo 请手动安装 Python 3.10-3.13
        echo 下载地址: https://www.python.org/downloads/
        pause
        exit /b 1
    ) else (
        echo 检测到 pyenv-win，准备安装 Python...
        goto :install_python_with_pyenv
    )
) else (
    echo ✅ Python 已安装
    python --version
    
    REM 检查 Python 版本是否符合要求 (3.10-3.13)
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo 当前版本: !PYTHON_VERSION!
    
    REM 简单版本检查（检查主版本号）
    echo !PYTHON_VERSION! | findstr /R "3\.1[0-3]\." >nul
    if errorlevel 1 (
        echo ⚠️  警告: Python 版本可能不兼容（需要 3.10-3.13）
        echo 当前版本: !PYTHON_VERSION!
        echo.
        choice /C YN /M "是否继续安装"
        if errorlevel 2 exit /b 1
    )
    
    goto :install_mineru
)

:install_python_with_pyenv
echo.
echo 使用 pyenv-win 安装 Python 3.11.9（推荐版本）...
echo.

REM 刷新环境变量
call refreshenv >nul 2>&1

REM 安装 Python 3.11.9
pyenv install 3.11.9

if errorlevel 1 (
    echo ❌ Python 安装失败
    echo.
    echo 请尝试:
    echo 1. 手动运行: pyenv install 3.11.9
    echo 2. 或安装其他版本: pyenv install 3.12.0
    echo 3. 查看可用版本: pyenv install --list
    pause
    exit /b 1
)

echo.
echo 设置 Python 3.11.9 为全局版本...
pyenv global 3.11.9
pyenv rehash

echo.
echo ✅ Python 3.11.9 安装成功！
python --version

REM ==========================================
REM 步骤 3: 升级 pip
REM ==========================================
:install_mineru
echo.
echo [步骤 3/5] 升级 pip...
echo.

python -m pip install --upgrade pip

if errorlevel 1 (
    echo ⚠️  pip 升级失败，尝试继续...
)

REM ==========================================
REM 步骤 4: 安装 uv
REM ==========================================
echo.
echo [步骤 4/5] 安装 uv 包管理器...
echo.

pip install uv

if errorlevel 1 (
    echo ❌ uv 安装失败
    pause
    exit /b 1
)

echo ✅ uv 安装成功

REM ==========================================
REM 步骤 5: 安装 MarkItDown
REM ==========================================
echo.
echo [步骤 5/6] 安装 MarkItDown（Word 转换引擎）...
echo.

pip install markitdown

if errorlevel 1 (
    echo ⚠️  MarkItDown 安装失败，但可以继续使用 MinerU
) else (
    echo ✅ MarkItDown 安装成功
)

REM ==========================================
REM 步骤 6: 安装 MinerU
REM ==========================================
echo.
echo [步骤 6/7] 安装 MinerU 3.0（PDF 转换引擎）...
echo 这可能需要几分钟时间，请耐心等待...
echo.
echo ⚠️  注意: 首次运行 MinerU 时需要下载模型文件（约 810MB）
echo.

python -m uv pip install --system -U "mineru[all]"

if errorlevel 1 (
    echo ❌ MinerU 安装失败
    echo.
    echo 故障排除:
    echo 1. 清理缓存: pip cache purge
    echo 2. 使用国内镜像: pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
    echo 3. 重新运行此脚本
    pause
    exit /b 1
)

echo ✅ MinerU 安装成功

REM ==========================================
REM 刷新 pyenv shims
REM ==========================================
echo.
echo [刷新环境] 更新 pyenv shims...
pyenv rehash

REM ==========================================
REM 验证安装
REM ==========================================
echo.
echo [验证] 检查安装...
echo.

REM 检查 MarkItDown
python -m markitdown --version >nul 2>&1
if errorlevel 1 (
    echo ⚠️  MarkItDown 未安装（Word 转换不可用）
) else (
    echo ✅ MarkItDown 安装成功！
    python -m markitdown --version
)

echo.

REM 检查 MinerU
mineru --version >nul 2>&1
if errorlevel 1 (
    echo ⚠️  MinerU 命令未找到（PDF 转换不可用）
    echo.
    echo 可能的原因:
    echo 1. 安装路径未添加到 PATH
    echo 2. 需要重启终端
    echo.
    echo 请尝试:
    echo 1. 关闭并重新打开终端
    echo 2. 运行: python -m magic_pdf --version
) else (
    echo ✅ MinerU 安装成功！
    mineru --version
)

echo.
echo =========================================
echo   安装完成！
echo =========================================
echo.
echo 📋 环境信息:
echo   Python: 
python --version
echo.
echo   MarkItDown (Word 转换): 
python -m markitdown --version 2>nul || echo 未安装
echo.
echo   MinerU (PDF 转换): 
mineru --version 2>nul || echo 未安装
echo.
echo 📖 使用方法:
echo   Word 转换:  python -m markitdown input.docx ^> output.md
echo   PDF 转换:   mineru -p input.pdf -o output/ -b pipeline
echo   批量转换:   mineru -p docs/ -o output/ -b pipeline
echo.
echo 💡 在 Kiro 中使用:
echo   直接说: "转换 docs/ai/xxx.pdf" 或 "转换 docs/ai/xxx.docx"
echo   系统会自动选择合适的引擎
echo.
echo 📚 更多帮助:
echo   查看文档: README.md
echo   命令帮助: mineru --help
echo   命令帮助: python -m markitdown --help
echo.
pause
