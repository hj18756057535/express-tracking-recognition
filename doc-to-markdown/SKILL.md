# Document to Markdown Conversion Skill

## 触发词

- `转换文档` / `convert document`
- `pdf转markdown` / `pdf2md`
- `word转markdown` / `docx2md`
- `文档转md` / `doc2md`

---

## 执行流程

### Step 1: 解析用户意图

从用户输入提取：
- **源路径**：文件或目录
- **输出路径**：默认同目录，或 `{源目录}_markdown`
- **转换模式**：单文件 / 批量

**示例解析**：
```
"转换 docs/api.pdf" → 源: docs/api.pdf, 输出: docs/api.md
"转换 docs/ 目录" → 源: docs/, 输出: docs_markdown/
```

### Step 2: 选择转换引擎

**引擎选择策略**：
```python
def select_engine(file_ext):
    # Word/Office → MarkItDown（更稳定）
    if file_ext in ['.docx', '.pptx', '.xlsx']:
        return 'markitdown'
    
    # PDF/图片 → MinerU（高精度）
    if file_ext in ['.pdf', '.jpg', '.png']:
        return 'mineru' if mineru_available() else 'markitdown'
    
    # 其他格式 → MarkItDown
    return 'markitdown'
```

**支持格式**：
- **MarkItDown**: `.docx`, `.pptx`, `.xlsx`, `.html`, `.json`, `.csv`, `.epub`
- **MinerU**: `.pdf`, `.jpg`, `.png`, `.gif`, `.bmp`, `.tiff`, `.webp`

### Step 3: 环境检查与准备

**1. 检查转换引擎**

检查 MarkItDown：
```bash
python -c "import markitdown; print('MarkItDown available')"
```
如不可用：`pip install markitdown`

检查 MinerU（可选）：
```bash
python -c "import magic_pdf; print('MinerU available')"
```
如不可用：提示运行 `install.bat` 或 `install.sh`

**2. 验证源路径**

使用 `readFile` 或 `listDirectory` 确认路径存在：
```python
# 单文件
if not Path(input_file).exists():
    # 列出相似文件供用户选择
    similar_files = find_similar_files(input_file)
    raise FileNotFoundError(f"文件不存在: {input_file}")

# 目录
if not Path(input_dir).is_dir():
    raise NotADirectoryError(f"目录不存在: {input_dir}")

# 检查文件格式
ext = Path(input_file).suffix.lower()
supported_formats = ['.pdf', '.docx', '.pptx', '.xlsx', '.jpg', '.png', ...]
if ext not in supported_formats:
    raise ValueError(f"不支持的格式: {ext}，支持的格式: {supported_formats}")
```

**3. 准备输出路径**

创建输出目录（如不存在）：
```python
output_dir = Path(output_path).parent
if not output_dir.exists():
    output_dir.mkdir(parents=True, exist_ok=True)
```

避免覆盖已有文件（询问用户）：
```python
if Path(output_file).exists():
    # 询问用户是否覆盖
    response = userInput(
        question=f"文件 {output_file} 已存在，是否覆盖？",
        options=["是", "否", "重命名"]
    )
    
    if response == "否":
        return  # 跳过转换
    elif response == "重命名":
        output_file = generate_unique_filename(output_file)
```

### Step 4: 执行转换

#### 方式 1: MarkItDown（Word/Office）

**Python API**：
```python
from markitdown import MarkItDown

def convert_with_markitdown(input_file, output_file):
    md = MarkItDown()
    result = md.convert(input_file)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(result.text_content)
    
    return output_file
```

**命令行**：
```bash
python -m markitdown input.docx > output.md
```

#### 方式 2: MinerU（PDF）

**命令行**：
```bash
mineru -p input.pdf -o output_dir/ -b pipeline
```

**Python API**：
```python
def convert_with_mineru(input_file, output_dir):
    cmd = f'mineru -p "{input_file}" -o "{output_dir}" -b pipeline'
    result = executePwsh(command=cmd, explanation="使用 MinerU 转换 PDF")
    
    # 读取生成的 Markdown
    output_file = Path(output_dir) / Path(input_file).with_suffix('.md').name
    if output_file.exists():
        return readFile(str(output_file), explanation="读取转换结果")
    else:
        raise Exception("转换失败")
```

#### 批量转换

```python
def batch_convert(input_dir, output_dir):
    files = list_directory(input_dir)
    
    for file in files:
        ext = Path(file).suffix.lower()
        
        if ext in ['.docx', '.pptx', '.xlsx']:
            convert_with_markitdown(file, output_dir)
        elif ext == '.pdf':
            convert_with_mineru(file, output_dir)
```

### Step 5: 错误处理

**智能降级**：
```python
def convert_with_fallback(input_file, output_file):
    ext = Path(input_file).suffix.lower()
    
    # Word 优先 MarkItDown
    if ext in ['.docx', '.pptx', '.xlsx']:
        try:
            return convert_with_markitdown(input_file, output_file)
        except:
            return convert_with_mineru(input_file, output_file)
    
    # PDF 优先 MinerU
    elif ext == '.pdf':
        try:
            return convert_with_mineru(input_file, output_file)
        except:
            return convert_with_markitdown(input_file, output_file)
```

**常见错误处理**：

| 错误 | 解决方案 |
|------|---------|
| MarkItDown 不可用 | `pip install markitdown` |
| MinerU 不可用 | 提示运行安装脚本或降级到 MarkItDown |
| 文件不存在 | 列出相似文件供选择 |
| 格式不支持 | 说明支持的格式 |
| 权限不足 | 建议更换输出位置 |

### Step 6: 生成报告

```
✅ 转换完成

📄 已转换: 2 个文件
  - docs/api.pdf → docs/api.md (使用 MinerU)
  - docs/guide.docx → docs/guide.md (使用 MarkItDown)

📁 输出目录: docs/
⏱️  总耗时: 8.5 秒
```

---

## 安装指引

**快速安装**：
- Windows: 运行 `install.bat`
- Linux/macOS: 运行 `install.sh`

**手动安装**：
```bash
# 最小安装（仅 Word）
pip install markitdown

# 完整安装（Word + PDF）
pip install markitdown
pip install uv
uv pip install -U "mineru[all]"
```

---

## 技术对比

| 维度 | MinerU 3.0 | MarkItDown |
|------|-----------|------------|
| **PDF 质量** | 90+ 分 ⭐ | 60 分 |
| **Word 稳定性** | 70 分 | 85 分 ⭐ |
| **安装难度** | 中等 | 简单 ⭐ |
| **资源需求** | 高（16GB+） | 低（4GB+）⭐ |

**推荐策略**：
- **PDF** → MinerU（高精度、OCR）
- **Word** → MarkItDown（更稳定、轻量）
