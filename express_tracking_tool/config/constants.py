"""
应用程序常量定义
"""

# 应用程序信息
APP_NAME = "快递单号自动识别填充工具"
APP_VERSION = "1.0.0"

# 文件相关常量
SUPPORTED_EXCEL_EXTENSIONS = ['.xlsx']
RULE_DATABASE_FILENAME = "courier_rules.json"
LOG_FILENAME = "app.log"

# 目录常量
CONFIG_DIR = "config"
LOGS_DIR = "logs"
DATA_DIR = "data"

# Excel模板相关常量
REQUIRED_COLUMNS = ["订单编号", "物流公司", "运单号"]
MIN_WORKSHEETS = 2
ORDER_SHEET_INDEX = 0
COURIER_LIST_SHEET_INDEX = 1

# 识别相关常量
UNRECOGNIZED_MARKER = "未识别"
DEFAULT_RULE_PRIORITY_START = 100

# UI相关常量
PROGRESS_UPDATE_INTERVAL = 10  # 每处理多少条记录更新一次进度
MIN_PROGRESS_DISPLAY_TIME = 2  # 最小进度显示时间（秒）

# 性能相关常量
MAX_PROCESSING_TIME = 10  # 最大处理时间（秒）
BATCH_SIZE = 100  # 批处理大小