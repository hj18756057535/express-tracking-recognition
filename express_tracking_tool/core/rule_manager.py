"""
规则库管理器
"""

import json
from pathlib import Path
from typing import List, Dict
from ..models.courier_rule import CourierRule


class RuleManager:
    """规则库管理器"""
    
    def __init__(self, rule_file_path: str):
        """初始化规则库管理器
        
        Args:
            rule_file_path: 规则库文件路径
        """
        self.rule_file_path = Path(rule_file_path)
        self.rules: List[CourierRule] = []
    
    def load_rules(self) -> bool:
        """加载规则库
        
        Returns:
            是否加载成功
        """
        try:
            if not self.rule_file_path.exists():
                return False
            
            with open(self.rule_file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            self.rules = []
            for rule_data in data.get('rules', []):
                rule = CourierRule.from_dict(rule_data)
                self.rules.append(rule)
            
            return True
            
        except Exception:
            return False
    
    def generate_default_rules(self, courier_list: list) -> None:
        """生成默认规则库
        
        Args:
            courier_list: [(快递公司名称, 编码), ...] 来自Excel sheet2
        """
        # 预定义运单号正则规则映射（按名称关键字匹配）
        predefined_patterns = {
            "顺丰": {
                "patterns": ["^SF\\d{10,12}$", "^SF\\d{8}$", "^\\d{12}$"],
                "description": "顺丰速运：SF前缀+数字，或12位纯数字"
            },
            "圆通": {
                "patterns": ["^YT\\d{10}$", "^YT\\d{8}$", "^[A-Za-z]{2}\\d{10}$", "^[6-9]\\d{17}$", "^Y\\d{12}$"],
                "description": "圆通速递：YT前缀+数字，或字母前缀+10位数字"
            },
            "中通快递": {
                "patterns": [
                    "^((768|765|778|828|618|680|518|528|688|010|880|660|805|988|628|205|717|718|728|761|762|763|701|757|719|751|358|100|200|118|128|689|738|359|779|852)\\d{9})$",
                    "^((5711|2008|7380|1180|2009|2013|2010|1000|1010)\\d{8})$",
                    "^((1111|90|36|11|50|53|37|39|91|93|94|95|96|98)\\d{10})$",
                    "^7[0-9]{13}$",
                    "^\\d{14}$"
                ],
                "description": "中通快递：多种前缀+数字组合，或14位纯数字"
            },
            "申通": {
                "patterns": ["^(888|588|688|468|568|668|768|868|968)\\d{9}$",
                             "^(11|22)\\d{10}$", "^STO\\d{10}$",
                             "^(37|33|44|55|66|77|88|99)\\d{11}$", "^4\\d{11}$"],
                "description": "申通快递：特定前缀+数字组合"
            },
            "韵达": {
                "patterns": [
                    "^(10|11|12|13|14|15|16|17|18|19|50|55|58|66|77|80|88|31|39)\\d{11}$",
                    "^\\d{13}$",
                    "^\\d{15}$"
                ],
                "description": "韵达快递：特定前缀+11位数字、13位或15位纯数字"
            },
            "极兔": {
                "patterns": ["^JT\\d{13}$", "^JT[A-Z0-9]{10,15}$"],
                "description": "极兔速递：JT前缀+数字"
            },
            "京东快递": {
                "patterns": ["^JD\\d{18}$", "^JDX\\d{12}$", "^\\d{15}$", "^\\d{18}$"],
                "description": "京东快递：JD前缀+数字或纯数字"
            },
            "邮政EMS": {
                "patterns": ["^[A-Z]{2}\\d{9}[A-Z]{2}$",
                             "^(10|11)\\d{11}$", "^(50|51)\\d{11}$", "^(95|97)\\d{11}$"],
                "description": "邮政EMS：2位字母+9位数字+2位字母"
            },
            "邮政快递包裹": {
                "patterns": ["^([GA]|[KQ]|[PH]){2}\\d{9}([2-5]\\d|[1][1-9]|[6][0-5])$",
                             "^99\\d{11}$", "^96\\d{11}$", "^98\\d{11}$"],
                "description": "邮政快递包裹：特定字母组合+数字"
            },
            "邮政电商标快": {
                "patterns": ["^99\\d{11}$", "^96\\d{11}$"],
                "description": "邮政电商标快：99/96开头+11位数字"
            },
            "安能": {
                "patterns": ["^\\d{15}$", "^AN\\d{13}$", "^\\d{12}$"],
                "description": "安能物流：15位数字或AN前缀+13位数字"
            },
            "德邦": {
                "patterns": ["^[5789]\\d{9}$"],
                "description": "德邦快递：5/7/8/9开头+9位数字"
            },
            "百世": {
                "patterns": ["^(A|B|D|E)\\d{12}$", "^BXA\\d{10}$",
                             "^K8\\d{11}$", "^02\\d{11}$", "^000\\d{10}$"],
                "description": "百世快递：字母前缀+数字组合"
            },
            "中通快运": {
                "patterns": ["^ZTO\\d{10}$"],
                "description": "中通快运：ZTO前缀+10位数字"
            },
        }
        
        self.rules = []
        priority_counter = 1
        
        for courier_name, courier_code in courier_list:
            # 按名称关键字匹配预定义规则
            matched = None
            for key, rule_data in predefined_patterns.items():
                if key in courier_name:
                    matched = rule_data
                    break
            
            if matched:
                rule = CourierRule(
                    courier_name=courier_name,
                    courier_code=courier_code,   # 使用sheet2中的编码
                    patterns=matched["patterns"],
                    priority=priority_counter,
                    description=matched["description"]
                )
                self.rules.append(rule)
            # 未匹配到预定义规则的快递公司直接跳过，不生成通用规则
            
            priority_counter += 1
    
    def get_rules(self) -> List[CourierRule]:
        """获取所有规则
        
        Returns:
            规则列表，按优先级排序
        """
        return sorted(self.rules, key=lambda r: r.priority)
    
    def save_rules(self) -> None:
        """保存规则库到文件"""
        # 确保目录存在
        self.rule_file_path.parent.mkdir(parents=True, exist_ok=True)
        
        data = {
            "version": "1.0",
            "rules": [rule.to_dict() for rule in self.rules]
        }
        
        with open(self.rule_file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)