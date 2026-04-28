"""
运单号识别引擎
"""

from typing import List, Optional
from ..models.courier_rule import CourierRule


class RecognitionEngine:
    """运单号识别引擎"""
    
    def __init__(self, rule_manager):
        """初始化识别引擎
        
        Args:
            rule_manager: 规则库管理器实例
        """
        self.rule_manager = rule_manager
    
    def recognize(self, tracking_number: str) -> Optional[str]:
        """识别运单号对应的快递公司编码
        
        Args:
            tracking_number: 运单号
            
        Returns:
            快递公司编码，未识别返回None
        """
        if not tracking_number or not tracking_number.strip():
            return None
        
        # 获取规则列表
        rules = self.rule_manager.get_rules()
        
        # 按优先级排序
        sorted_rules = sorted(rules, key=lambda r: r.priority)
        
        # 遍历规则进行匹配
        for rule in sorted_rules:
            if rule.matches(tracking_number):
                return rule.courier_code
        
        return None
    
    def batch_recognize(self, tracking_numbers: List[str]) -> List[Optional[str]]:
        """批量识别运单号
        
        Args:
            tracking_numbers: 运单号列表
            
        Returns:
            快递公司编码列表
        """
        results = []
        for tracking_number in tracking_numbers:
            result = self.recognize(tracking_number)
            results.append(result)
        return results