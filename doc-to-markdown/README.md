# 文档转 Markdown Skill

高质量文档转换工具。智能选择引擎：PDF 用 MinerU（高精度），Word 用 MarkItDown（更稳定）。

## 🌟 特性

- ✅ **智能引擎选择**：自动为不同格式选择最佳引擎
- ✅ **高精度 PDF**：86-90+ 分（OmniDocBench 评测）
- ✅ **稳定 Word 转换**：MarkItDown 专业处理 Office 文档
- ✅ **轻量安装**：最小安装仅需 MarkItDown（4GB RAM）
- ✅ **OCR 支持**：MinerU 支持 109 种语言扫描件识别

## 📦 安装

### 一键安装（推荐）

**Windows**:
```bash
install.bat
```

**Linux/macOS**:
```bash
chmod +x install.sh
./install.sh
```

### 手动安装

```bash
# 最小安装（仅 Word 转换，4GB RAM）
pip install markitdown

# 完整安装（Word + PDF，16GB+ RAM）
pip install markitdown
pip install uv
uv pip install -U "mineru[all]"
```

## 🚀 使用

### 在 Kiro 中使用

```
"转换 docs/api.pdf"
"转换 docs/guide.docx"
"转换 docs/ 目录"
```

### 命令行使用

```bash
# Word 文档
python -m markitdown input.docx > output.md

# PDF 文档
mineru -p input.pdf -o output/ -b pipeline
```

## 📋 支持格式

| 格式 | 推荐引擎 | 说明 |
|------|---------|------|
| `.docx`, `.pptx`, `.xlsx` | MarkItDown ⭐ | 更稳定 |
| `.pdf` | MinerU ⭐ | 高精度 |
| `.jpg`, `.png` | MinerU | OCR 支持 |
| `.html`, `.json`, `.csv` | MarkItDown | 29+ 格式 |

## 🎯 引擎对比

| 维度 | MinerU | MarkItDown |
|------|--------|------------|
| PDF 质量 | 90+ 分 ⭐ | 60 分 |
| Word 稳定性 | 70 分 | 85 分 ⭐ |
| 安装难度 | 中等 | 简单 ⭐ |
| 资源需求 | 16GB+ | 4GB+ ⭐ |

## 🐛 故障排除

### MarkItDown 未安装

```bash
pip install markitdown
```

### MinerU 未安装

```bash
# 运行安装脚本
install.bat  # Windows
./install.sh # Linux/macOS
```

### 命令未找到

**Windows**: 重启终端或运行 `refreshenv`

**Linux/macOS**: 运行 `source ~/.bashrc` 或 `source ~/.zshrc`



## ⚡ 快速命令参考

```bash
# pyenv 常用命令
pyenv install --list      # 列出可安装版本
pyenv install 3.11.9      # 安装指定版本
pyenv versions            # 列出已安装版本
pyenv global 3.11.9       # 设置全局版本

# MarkItDown 常用命令
python -m markitdown input.docx > output.md     # Word 转换
python -m markitdown input.pdf > output.md      # PDF 转换
python -m markitdown --version                  # 查看版本

# MinerU 常用命令
mineru --version          # 查看版本
mineru --help             # 查看帮助
mineru -p input.pdf -o output/ -b pipeline  # 基本转换
mineru -p docs/ -o output/ -b pipeline      # 批量转换
mineru -p input.pdf -o output/ -b vlm       # GPU 加速

# pip 常用命令
pip list                  # 列出已安装包
pip show markitdown       # 查看包信息
pip cache purge           # 清理缓存
```

## 🎓 进阶使用

### 自定义输出格式

```bash
# 输出为 JSON 格式
mineru -p input.pdf -o output/ --output-format json

# 输出为带布局的 Markdown
mineru -p input.pdf -o output/ --output-format md_with_layout
```

## 📖 更多资源

- [MinerU GitHub](https://github.com/opendatalab/MinerU)
- [MarkItDown GitHub](https://github.com/microsoft/markitdown)
- [在线体验 MinerU](https://mineru.net)
- [pyenv GitHub](https://github.com/pyenv/pyenv)
- [pyenv-win GitHub](https://github.com/pyenv-win/pyenv-win)

## 📄 许可证

MIT 许可证。MinerU 使用 AGPLv3，MarkItDown 使用 MIT。
