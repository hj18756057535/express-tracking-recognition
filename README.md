# 快递单号自动识别填充工具

一个基于Python的桌面应用程序，用于自动识别Excel模板中的快递运单号并填充对应的快递公司编码。

## 功能特性

- 🚀 自动识别14种主要快递公司的运单号格式
- 📊 支持Excel文件(.xlsx)的批量处理
- 🎯 基于正则表达式的高精度识别算法
- 🔧 可维护的本地规则库
- 💻 简洁友好的图形用户界面
- 📈 实时处理进度显示
- 📝 详细的处理结果统计

## 支持的快递公司

- 顺丰速运 (SF)
- 圆通速递 (YTO)
- 中通快递 (ZTO)
- 申通快递 (STO)
- 韵达快递 (YUNDA)
- 极兔速递 (JT)
- 京东快递 (JD)
- 邮政EMS (EMS)
- 邮政快递包裹 (POSTB)
- 安能物流 (ANE)
- 德邦快递 (DBKD)
- 百世快递 (HTKY)
- 中通快运 (ZTO_KY)

## 系统要求

- Python 3.8+
- Windows 操作系统
- Excel 2007+ (.xlsx格式)

## 安装说明

### 1. 克隆项目
```bash
git clone <repository-url>
cd express-tracking-tool
```

### 2. 创建虚拟环境
```bash
python -m venv venv
venv\Scripts\activate  # Windows
```

### 3. 安装依赖
```bash
pip install -r requirements.txt
```

### 4. 运行程序
```bash
python express_tracking_tool/main.py
```

## Excel模板格式

### 第一个工作表（订单数据）
| 订单编号 | 物流公司 | 运单号 |
|---------|---------|--------|
| ORD001  |         | SF1234567890 |
| ORD002  |         | 1234567890123 |

### 第二个工作表（快递公司列表）
| 快递公司名称 |
|------------|
| 顺丰速运    |
| 中通快递    |
| 圆通速递    |

## 使用说明

1. 启动程序后，选择要处理的Excel文件
2. 程序自动验证文件格式
3. 读取快递公司列表并生成/加载规则库
4. 批量识别运单号并填充快递公司编码
5. 显示处理结果统计

## 项目结构

```
express_tracking_tool/
├── __init__.py
├── main.py                 # 主程序入口
├── models/                 # 数据模型
│   ├── __init__.py
│   └── courier_rule.py     # 快递规则模型
├── core/                   # 核心业务逻辑
│   ├── __init__.py
│   ├── file_manager.py     # 文件管理器
│   ├── recognition_engine.py # 识别引擎
│   ├── rule_manager.py     # 规则管理器
│   └── error_handler.py    # 错误处理器
├── ui/                     # 用户界面
│   ├── __init__.py
│   └── ui_manager.py       # UI管理器
└── config/                 # 配置管理
    ├── __init__.py
    ├── constants.py        # 常量定义
    └── settings.py         # 设置管理
```

## 配置文件

- `config/app_config.json`: 应用程序配置
- `data/courier_rules.json`: 快递规则库（自动生成）
- `logs/app.log`: 应用程序日志

## 开发说明

### 添加新的快递公司规则

编辑 `express_tracking_tool/core/rule_manager.py` 中的 `predefined_rules` 字典，添加新的快递公司规则。

### 自定义规则库

规则库文件位于 `data/courier_rules.json`，可以手动编辑添加或修改规则。

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request来改进这个项目。

打包命令
```

pyinstaller --onefile --windowed --name="express_tracking_tool" --distpath dist express_tracking_tool/main.py 2>&1 | Select-String -Pattern "(ERROR|completed successfully|Build complete)"

```
