"""
应用程序设置管理
"""

import json
from pathlib import Path
from typing import Dict, Any


class Settings:
    """应用程序设置管理器"""
    
    def __init__(self, config_file: str = "config/app_config.json"):
        """初始化设置管理器
        
        Args:
            config_file: 配置文件路径
        """
        self.config_file = Path(config_file)
        self._settings = self._load_default_settings()
        self.load()
    
    def _load_default_settings(self) -> Dict[str, Any]:
        """加载默认设置"""
        return {
            "rule_database_path": "data/courier_rules.json",
            "log_level": "INFO",
            "log_file_path": "logs/app.log",
            "ui": {
                "show_progress": True,
                "progress_update_interval": 10
            },
            "processing": {
                "batch_size": 100,
                "max_processing_time": 10
            }
        }
    
    def load(self) -> bool:
        """从文件加载设置
        
        Returns:
            是否加载成功
        """
        try:
            if self.config_file.exists():
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    file_settings = json.load(f)
                    self._settings.update(file_settings)
                return True
        except Exception:
            pass
        return False
    
    def save(self) -> bool:
        """保存设置到文件
        
        Returns:
            是否保存成功
        """
        try:
            # 确保目录存在
            self.config_file.parent.mkdir(parents=True, exist_ok=True)
            
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(self._settings, f, ensure_ascii=False, indent=2)
            return True
        except Exception:
            return False
    
    def get(self, key: str, default=None):
        """获取设置值
        
        Args:
            key: 设置键，支持点号分隔的嵌套键（如 "ui.show_progress"）
            default: 默认值
            
        Returns:
            设置值
        """
        keys = key.split('.')
        value = self._settings
        
        try:
            for k in keys:
                value = value[k]
            return value
        except (KeyError, TypeError):
            return default
    
    def set(self, key: str, value: Any) -> None:
        """设置值
        
        Args:
            key: 设置键，支持点号分隔的嵌套键
            value: 设置值
        """
        keys = key.split('.')
        target = self._settings
        
        # 导航到目标位置
        for k in keys[:-1]:
            if k not in target:
                target[k] = {}
            target = target[k]
        
        # 设置值
        target[keys[-1]] = value
    
    @property
    def rule_database_path(self) -> str:
        """规则库文件路径"""
        return self.get("rule_database_path", "data/courier_rules.json")
    
    @property
    def log_file_path(self) -> str:
        """日志文件路径"""
        return self.get("log_file_path", "logs/app.log")
    
    @property
    def batch_size(self) -> int:
        """批处理大小"""
        return self.get("processing.batch_size", 100)
    
    @property
    def progress_update_interval(self) -> int:
        """进度更新间隔"""
        return self.get("ui.progress_update_interval", 10)