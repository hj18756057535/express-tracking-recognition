"""
错误处理器
"""

import logging
from pathlib import Path
from typing import Optional


class ErrorHandler:
    """错误处理器"""
    
    _logger = None
    _log_dir: Path = Path("logs")  # 默认值，可通过 setup() 覆盖

    @classmethod
    def setup(cls, log_dir: Path):
        """设置日志目录（必须在第一次使用前调用）"""
        cls._log_dir = log_dir
        cls._logger = None  # 重置，下次使用时重新初始化
    
    @classmethod
    def _get_logger(cls):
        """获取日志记录器"""
        if cls._logger is None:
            cls._log_dir.mkdir(parents=True, exist_ok=True)
            
            cls._logger = logging.getLogger("express_tracking_tool")
            cls._logger.setLevel(logging.INFO)
            
            # 避免重复添加handler
            if not cls._logger.handlers:
                file_handler = logging.FileHandler(
                    cls._log_dir / "app.log",
                    encoding='utf-8'
                )
                file_handler.setLevel(logging.INFO)
                formatter = logging.Formatter(
                    '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
                )
                file_handler.setFormatter(formatter)
                cls._logger.addHandler(file_handler)
        
        return cls._logger
    
    @staticmethod
    def handle_exception(exception: Exception) -> str:
        """处理异常并返回用户友好的错误消息
        
        Args:
            exception: 异常对象
            
        Returns:
            用户友好的错误消息
        """
        error_messages = {
            FileNotFoundError: "文件未找到，请检查文件路径是否正确",
            PermissionError: "文件被其他程序占用或没有访问权限，请关闭相关程序后重试",
            ValueError: "数据格式错误，请检查Excel文件格式",
            KeyError: "Excel文件格式不正确，缺少必要的列",
            Exception: "发生未知错误，请查看日志文件获取详细信息"
        }
        
        # 记录错误日志
        ErrorHandler.log_error(f"异常类型: {type(exception).__name__}, 消息: {str(exception)}", exception)
        
        # 返回用户友好的错误消息
        for error_type, message in error_messages.items():
            if isinstance(exception, error_type):
                return message
        
        return error_messages[Exception]
    
    @staticmethod
    def log_error(message: str, exception: Optional[Exception] = None) -> None:
        """记录错误日志
        
        Args:
            message: 错误消息
            exception: 异常对象（可选）
        """
        logger = ErrorHandler._get_logger()
        
        if exception:
            logger.error(f"{message}", exc_info=True)
        else:
            logger.error(message)
    
    @staticmethod
    def log_info(message: str) -> None:
        """记录信息日志
        
        Args:
            message: 信息消息
        """
        logger = ErrorHandler._get_logger()
        logger.info(message)