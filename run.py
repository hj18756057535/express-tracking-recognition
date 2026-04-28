#!/usr/bin/env python
"""
快递单号自动识别填充工具启动脚本
"""

import sys
from pathlib import Path

# 添加项目根目录到Python路径
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

from express_tracking_tool.main import main

if __name__ == "__main__":
    main()