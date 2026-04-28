@echo off
REM ==========================================
REM 文档转 Markdown 安装脚本 - 国内网络适配版 (Windows)
REM 基于原始 install.bat，针对中国大陆网络环境优化
REM
REM 优化项:
REM   1. pip/uv 使用清华大学镜像源
REM   2. pyenv-win VBS 源码镜像修改（扫描+下载）
REM   3. pyenv-win XML 缓存 URL 替换
REM   4. 自动修复 PowerShell 执行策略
REM   5. 完善的错误处理和重试机制
REM
REM ⚠️ 关键说明:
REM   pyenv-win 的 mirrors.txt 只是展示信息，不影响实际下载！
REM   真正控制下载源的有 3 处:
REM     1. pyenv-install-lib.vbs 中的 mirrors 数组（扫描源）
REM     2. pyenv-install-lib.vbs 的 DownloadFile 函数（下载时 URL 重定向）
REM     3. .versions_cache.xml 中的 URL（缓存的下载地址）
REM   本脚本会自动修改以上 3 处，确保从国内镜像下载
REM ==========================================

setlocal enabledelayedexpansion

echo =========================================
echo   文档转 Markdown 安装脚本 (国内版)
echo   MinerU (PDF) + MarkItDown (Word)
echo   国内网络优化
echo =========================================
echo.

REM ==========================================
REM 配置国内镜像源
REM ==========================================
set PIP_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple
set UV_MIRROR=https://pypi.tuna.tsinghua.edu.cn/simple
set PYENV_MIRROR=https://repo.huaweicloud.com/python

echo 镜像源配置:
echo   pip:  %PIP_MIRROR%
echo   uv:   %UV_MIRROR%
echo   pyenv: %PYENV_MIRROR%
echo.

REM ==========================================
REM 步骤 0: 修复 PowerShell 执行策略
REM ==========================================
echo [步骤 0/7] 检查 PowerShell 执行策略...
echo.

powershell -Command "Get-ExecutionPolicy" 2>nul | findstr /I "RemoteSigned Unrestricted Bypass" >nul 2>&1
if errorlevel 1 (
    echo   PowerShell 执行策略可能阻止 pyenv-win 运行
    echo   需要调整为 RemoteSigned
    echo.
    choice /C YN /M "是否自动修复执行策略"
    if errorlevel 2 goto :skip_policy_fix
    if errorlevel 1 goto :fix_policy
) else (
    echo   PowerShell 执行策略正常
    goto :check_pyenv
)

:fix_policy
echo.
echo 正在修复 PowerShell 执行策略...
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"
if errorlevel 1 (
    echo   自动修复失败，请手动执行:
    echo    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    echo.
    pause
    exit /b 1
)
echo   PowerShell 执行策略已修复为 RemoteSigned
echo.

:skip_policy_fix
echo 跳过执行策略修复
echo.

REM ==========================================
REM 步骤 1: 检查 pyenv-win
REM ==========================================
:check_pyenv
echo [步骤 1/7] 检查 Python 环境管理器...
echo.

pyenv --version >nul 2>&1
if errorlevel 1 (
    echo   未检测到 pyenv-win
    echo.
    choice /C YN /M "是否安装 pyenv-win（推荐）"
    if errorlevel 2 goto :skip_pyenv
    if errorlevel 1 goto :install_pyenv
) else (
    echo   pyenv-win 已安装
    pyenv --version
    goto :check_python
)

:install_pyenv
echo.
echo 正在安装 pyenv-win...
echo.

REM 尝试使用 PowerShell 方式（使用 GitHub 代理）
echo 尝试使用 PowerShell 安装（国内代理）...
powershell -Command "Invoke-WebRequest -UseBasicParsing -Uri 'https://ghp.ci/https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1' -OutFile './install-pyenv-win.ps1'; & './install-pyenv-win.ps1'"

if errorlevel 1 (
    echo   pyenv-win 安装失败
    echo.
    echo 请手动安装:
    echo 1. 访问: https://github.com/pyenv-win/pyenv-win
    echo 2. 或使用 Git: git clone https://github.com/pyenv-win/pyenv-win.git "%%USERPROFILE%%\.pyenv"
    echo 3. 添加环境变量后重启终端
    echo.
    pause
    exit /b 1
)

echo   pyenv-win 安装成功！
echo   重要: 请关闭当前终端，重新打开后再次运行此脚本
pause
exit /b 0

:skip_pyenv
echo 跳过 pyenv-win 安装，将使用系统 Python
echo.

REM ==========================================
REM 步骤 2: 安装 Python
REM ==========================================
:check_python
echo.
echo [步骤 2/7] 检查 Python 环境...
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo   未检测到 Python
    echo.

    pyenv --version >nul 2>&1
    if errorlevel 1 (
        echo 请手动安装 Python 3.10-3.13
        echo 国内下载: https://mirrors.huaweicloud.com/python/
        echo 官方下载: https://www.python.org/downloads/
        pause
        exit /b 1
    ) else (
        echo 检测到 pyenv-win，准备安装 Python...
        goto :install_python_with_pyenv
    )
) else (
    echo   Python 已安装
    python --version

    REM 检查 Python 版本是否符合要求 (3.10-3.13)
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo 当前版本: !PYTHON_VERSION!

    echo !PYTHON_VERSION! | findstr /R "3\.1[0-3]\." >nul
    if errorlevel 1 (
        echo   警告: Python 版本可能不兼容（需要 3.10-3.13）
        echo 当前版本: !PYTHON_VERSION!
        echo.
        choice /C YN /M "是否继续安装"
        if errorlevel 2 exit /b 1
    )

    goto :configure_pip_mirror
)

:install_python_with_pyenv
echo.
echo 使用 pyenv-win 安装 Python 3.11.9（推荐版本）...
echo.

REM ==========================================
REM 关键: 配置 pyenv-win 国内镜像（3 层修改）
REM ==========================================
echo 正在配置 pyenv-win 国内镜像源...
echo.

REM --- 第 1 层: 修改 VBS 中的硬编码扫描镜像 ---
set PYENV_LIB_VBS=%USERPROFILE%\.pyenv\pyenv-win\libexec\libs\pyenv-install-lib.vbs
if exist "!PYENV_LIB_VBS!" (
    findstr /C:"npmmirror.com" "!PYENV_LIB_VBS!" >nul 2>&1
    if errorlevel 1 (
        echo [1/3] 修改 pyenv-install-lib.vbs 中的扫描镜像源...
        echo   官方源 -> 国内镜像源（华为云 + npmmirror + 官方备用）
        powershell -Command "$p='!PYENV_LIB_VBS!'; $c=[System.IO.File]::ReadAllText($p,[System.Text.Encoding]::UTF8); $c=$c -replace 'https://www\.python\.org/ftp/python','https://repo.huaweicloud.com/python' -replace 'https://downloads\.python\.org/pypy/versions\.json','https://npmmirror.com/mirrors/python' -replace 'https://api\.github\.com/repos/oracle/graalpython/releases','https://www.python.org/ftp/python'; [System.IO.File]::WriteAllText($p,$c,(New-Object System.Text.UTF8Encoding($false)))"
        echo   VBS 扫描镜像源已修改
    ) else (
        echo [1/3] VBS 扫描镜像源已是国内镜像，跳过
    )
) else (
    echo [1/3] 未找到 pyenv-install-lib.vbs
)

REM --- 第 2 层: 修改 VBS 的 DownloadFile 函数（下载时 URL 自动重定向） ---
if exist "!PYENV_LIB_VBS!" (
    findstr /C:"npmmirror.com/mirrors/python" "!PYENV_LIB_VBS!" >nul 2>&1
    if errorlevel 1 (
        echo [2/3] 添加 VBS 下载时 URL 自动重定向...
        powershell -Command "$p='!PYENV_LIB_VBS!'; $c=[System.IO.File]::ReadAllText($p,[System.Text.Encoding]::UTF8); $old=\"' Download exe file`r`nFunction DownloadFile(strUrl, strFile)\"; $new=\"' Download exe file`r`nFunction DownloadFile(strUrl, strFile)`r`n    ' China mirror: auto-replace official URL with npmmirror`r`n    If InStr(strUrl, `\"www.python.org/ftp/python`\") > 0 Then`r`n        strUrl = Replace(strUrl, `\"www.python.org/ftp/python`\", `\"npmmirror.com/mirrors/python`\")`r`n        WScript.Echo `\":: [Mirror] ::  Redirected to China mirror: `\" & strUrl`r`n    End If\"; $c=$c.Replace($old,$new); [System.IO.File]::WriteAllText($p,$c,(New-Object System.Text.UTF8Encoding($false)))"
        echo   VBS 下载重定向已添加
    ) else (
        echo [2/3] VBS 下载重定向已存在，跳过
    )
) else (
    echo [2/3] 未找到 pyenv-install-lib.vbs
)

REM --- 第 3 层: 替换 XML 缓存中的下载 URL ---
set PYENV_CACHE_XML=%USERPROFILE%\.pyenv\pyenv-win\.versions_cache.xml
if exist "!PYENV_CACHE_XML!" (
    echo [3/3] 替换版本缓存 XML 中的下载 URL...
    powershell -Command "$p='!PYENV_CACHE_XML!'; $c=[System.IO.File]::ReadAllText($p,[System.Text.Encoding]::UTF8); $c=$c -replace 'https://www\.python\.org/ftp/python','https://npmmirror.com/mirrors/python'; [System.IO.File]::WriteAllText($p,$c,(New-Object System.Text.UTF8Encoding($false)))"
    echo   XML 缓存 URL 已替换
) else (
    echo [3/3] 版本缓存 XML 不存在，首次 pyenv install 会自动创建
)

REM 同时设置环境变量（备用方案）
set PYTHON_BUILD_MIRROR_URL=https://repo.huaweicloud.com/python

REM 更新 mirrors.txt 文件（信息展示用）
echo %PYENV_MIRROR%/> "%USERPROFILE%\.pyenv\mirrors.txt"
echo %PYENV_MIRROR%/> "%USERPROFILE%\.pyenv\pyenv-win\mirrors.txt"

echo.
echo 镜像配置完成，正在下载 Python 3.11.9（国内镜像加速）...
echo.

pyenv install 3.11.9

if errorlevel 1 (
    echo   Python 安装失败
    echo.
    echo 请尝试:
    echo 1. 手动运行: pyenv install 3.11.9
    echo 2. 或安装其他版本: pyenv install 3.12.0
    echo 3. 查看可用版本: pyenv install --list
    echo 4. 国内手动下载: https://mirrors.huaweicloud.com/python/3.11.9/
    pause
    exit /b 1
)

echo.
echo 设置 Python 3.11.9 为全局版本...
pyenv global 3.11.9
pyenv rehash

echo.
echo   Python 3.11.9 安装成功！
python --version

REM ==========================================
REM 步骤 3: 配置 pip 国内镜像并升级
REM ==========================================
:configure_pip_mirror
echo.
echo [步骤 3/7] 配置 pip 国内镜像源并升级...
echo.

echo 正在配置 pip 使用清华大学镜像源...
pip config set global.index-url %PIP_MIRROR%
pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn

echo   pip 镜像源已配置为: %PIP_MIRROR%
echo.

echo 正在升级 pip...
python -m pip install --upgrade pip -i %PIP_MIRROR% --trusted-host pypi.tuna.tsinghua.edu.cn

if errorlevel 1 (
    echo   pip 升级失败，尝试继续...
) else (
    echo   pip 升级成功
)

REM ==========================================
REM 步骤 4: 安装 uv
REM ==========================================
echo.
echo [步骤 4/7] 安装 uv 包管理器（国内镜像加速）...
echo.

pip install uv -i %PIP_MIRROR% --trusted-host pypi.tuna.tsinghua.edu.cn

if errorlevel 1 (
    echo   uv 安装失败，尝试使用官方安装脚本...
    powershell -Command "irm https://ghp.ci/https://astral.sh/uv/install.ps1 | iex"
    if errorlevel 1 (
        echo   uv 安装仍然失败
        pause
        exit /b 1
    )
)

echo   uv 安装成功

REM ==========================================
REM 步骤 5: 安装 MarkItDown
REM ==========================================
echo.
echo [步骤 5/7] 安装 MarkItDown（Word 转换引擎，国内镜像加速）...
echo.

pip install markitdown -i %PIP_MIRROR% --trusted-host pypi.tuna.tsinghua.edu.cn

if errorlevel 1 (
    echo   MarkItDown 安装失败，尝试不带 trusted-host...
    pip install markitdown -i %PIP_MIRROR%
    if errorlevel 1 (
        echo   MarkItDown 安装失败
        echo.
        choice /C YN /M "是否继续安装 MinerU"
        if errorlevel 2 exit /b 1
        goto :install_mineru
    )
) else (
    echo   MarkItDown 安装成功
)

REM ==========================================
REM 步骤 6: 安装 MinerU
REM ==========================================
:install_mineru
echo.
echo [步骤 6/7] 安装 MinerU 3.0（PDF 转换引擎，国内镜像加速）...
echo 这可能需要几分钟时间，请耐心等待...
echo.
echo   注意: 首次运行 MinerU 时需要下载模型文件（约 810MB）
echo.

python -m uv pip install --system -U "mineru[all]" --index-url %UV_MIRROR% --trusted-host pypi.tuna.tsinghua.edu.cn

if errorlevel 1 (
    echo   uv 安装 MinerU 失败，尝试使用 pip...
    pip install "mineru[all]" -i %PIP_MIRROR% --trusted-host pypi.tuna.tsinghua.edu.cn

    if errorlevel 1 (
        echo   MinerU 安装失败
        echo.
        echo 故障排除:
        echo 1. 清理缓存: pip cache purge
        echo 2. 检查网络: ping pypi.tuna.tsinghua.edu.cn
        echo 3. 重新运行此脚本
        echo 4. 仅安装 MarkItDown: pip install markitdown
        pause
        exit /b 1
    )
)

echo   MinerU 安装成功

REM ==========================================
REM 刷新 pyenv shims
REM ==========================================
echo.
echo [刷新环境] 更新 pyenv shims...
pyenv rehash 2>nul

REM ==========================================
REM 步骤 7: 验证安装
REM ==========================================
echo.
echo [步骤 7/7] 验证安装...
echo.

echo -------------------------------------------
echo   安装验证报告
echo -------------------------------------------
echo.

echo [Python]
python --version 2>nul
if errorlevel 1 (
    echo   Python 不可用 - 可能需要重启终端
) else (
    echo   Python 正常
)
echo.

echo [pip]
pip --version 2>nul
if errorlevel 1 (
    echo   pip 不可用
) else (
    echo   pip 正常
)
echo.

echo [MarkItDown - Word 转换引擎]
python -m markitdown --version >nul 2>&1
if errorlevel 1 (
    echo   MarkItDown 未安装（Word 转换不可用）
) else (
    echo   MarkItDown 安装成功！
    python -m markitdown --version
)
echo.

echo [MinerU - PDF 转换引擎]
mineru --version >nul 2>&1
if errorlevel 1 (
    echo   MinerU 命令未找到
    echo.
    echo 可能的原因:
    echo 1. 安装路径未添加到 PATH
    echo 2. 需要重启终端
    echo.
    echo 请尝试:
    echo 1. 关闭并重新打开终端
    echo 2. 运行: python -m magic_pdf.cli --version
) else (
    echo   MinerU 安装成功！
    mineru --version
)
echo.

echo [pip 镜像配置]
pip config get global.index-url 2>nul || echo 未配置
echo.

echo =========================================
echo   安装完成！
echo =========================================
echo.
echo 环境信息:
echo   Python:
python --version 2>nul || echo   未安装
echo   MarkItDown (Word 转换):
python -m markitdown --version 2>nul || echo   未安装
echo   MinerU (PDF 转换):
mineru --version 2>nul || echo   未安装
echo.
echo 使用方法:
echo   Word 转换:  python -m markitdown input.docx ^> output.md
echo   PDF 转换:   mineru -p input.pdf -o output/ -b pipeline
echo   批量转换:   mineru -p docs/ -o output/ -b pipeline
echo.
echo 国内镜像已配置:
echo   pip: %PIP_MIRROR%
echo   pyenv 扫描: 华为云 + npmmirror + 官方备用
echo   pyenv 下载: npmmirror 自动重定向
echo.
echo 在 IDE 中使用:
echo   直接说: "转换 docs/ai/xxx.pdf" 或 "转换 docs/ai/xxx.docx"
echo   系统会自动选择合适的引擎
echo.
echo 更多帮助:
echo   查看文档: README.md
echo   命令帮助: mineru --help
echo   命令帮助: python -m markitdown --help
echo.

pause
