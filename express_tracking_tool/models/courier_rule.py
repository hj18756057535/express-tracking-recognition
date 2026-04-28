"""
快递公司规则数据模型
"""

import re
from dataclasses import dataclass
from typing import List


@dataclass
class CourierRule:
    """快递公司规则"""
    courier_name: str          # 快递公司名称
    courier_code: str          # 快递公司编码
    patterns: List[str]        # 正则表达式模式列表
    priority: int              # 优先级（数字越小优先级越高）
    description: str           # 规则描述
    
    def matches(self, tracking_number: str) -> bool:
        """检查运单号是否匹配此规则
        
        Args:
            tracking_number: 运单号
            
        Returns:
            是否匹配
        """
        if not tracking_number or not tracking_number.strip():
            return False
            
        cleaned_number = tracking_number.strip()
        
        for pattern in self.patterns:
            try:
                if re.match(pattern, cleaned_number):
                    return True
            except re.error:
                # 如果正则表达式有错误，跳过这个模式
                continue
                
        return False
    
    def to_dict(self) -> dict:
        """转换为字典格式"""
        return {
            'courier_name': self.courier_name,
            'courier_code': self.courier_code,
            'patterns': self.patterns,
            'priority': self.priority,
            'description': self.description
        }
    
    @classmethod
    def from_dict(cls, data: dict) -> 'CourierRule':
        """从字典创建规则对象"""
        return cls(
            courier_name=data['courier_name'],
            courier_code=data['courier_code'],
            patterns=data['patterns'],
            priority=data['priority'],
            description=data['description']
        )