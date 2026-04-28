#!/usr/bin/env python
"""
基本功能测试脚本
"""

import sys
from pathlib import Path

# 添加项目根目录到Python路径
project_root = Path(__file__).parent
sys.path.insert(0, str(project_root))

from express_tracking_tool.models.courier_rule import CourierRule
from express_tracking_tool.core.rule_manager import RuleManager
from express_tracking_tool.core.recognition_engine import RecognitionEngine


def test_courier_rule():
    """测试CourierRule类"""
    print("测试CourierRule类...")
    
    # 创建规则
    rule = CourierRule(
        courier_name="顺丰速运",
        courier_code="SF",
        patterns=["^[A-Za-z0-9-]{4,35}$"],
        priority=1,
        description="顺丰速运：4-35位字母数字组合"
    )
    
    # 测试匹配
    assert rule.matches("SF1234567890") == True
    assert rule.matches("123") == False
    assert rule.matches("") == False
    
    # 测试序列化
    rule_dict = rule.to_dict()
    assert rule_dict["courier_name"] == "顺丰速运"
    
    # 测试反序列化
    rule2 = CourierRule.from_dict(rule_dict)
    assert rule2.courier_name == rule.courier_name
    
    print("✓ CourierRule类测试通过")


def test_rule_manager():
    """测试RuleManager类"""
    print("测试RuleManager类...")
    
    # 创建临时规则管理器
    rule_manager = RuleManager("test_rules.json")
    
    # 生成默认规则
    courier_names = ["顺丰速运", "中通快递", "圆通速递"]
    rule_manager.generate_default_rules(courier_names)
    
    # 检查规则数量
    rules = rule_manager.get_rules()
    assert len(rules) == 3
    
    # 检查顺丰规则
    sf_rule = next((r for r in rules if r.courier_code == "SF"), None)
    assert sf_rule is not None
    assert sf_rule.courier_name == "顺丰速运"
    
    print("✓ RuleManager类测试通过")


def test_recognition_engine():
    """测试RecognitionEngine类"""
    print("测试RecognitionEngine类...")
    
    # 创建规则管理器
    rule_manager = RuleManager("test_rules.json")
    courier_names = ["顺丰速运", "中通快递"]
    rule_manager.generate_default_rules(courier_names)
    
    # 创建识别引擎
    engine = RecognitionEngine(rule_manager)
    
    # 测试识别
    result = engine.recognize("SF1234567890")
    assert result == "SF"
    
    result = engine.recognize("invalid")
    assert result is None
    
    # 测试批量识别
    results = engine.batch_recognize(["SF1234567890", "invalid", ""])
    assert results[0] == "SF"
    assert results[1] is None
    assert results[2] is None
    
    print("✓ RecognitionEngine类测试通过")


def main():
    """运行所有测试"""
    print("开始基本功能测试...\n")
    
    try:
        test_courier_rule()
        test_rule_manager()
        test_recognition_engine()
        
        print("\n🎉 所有测试通过！项目结构搭建成功。")
        
    except Exception as e:
        print(f"\n❌ 测试失败: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    finally:
        # 清理测试文件
        test_file = Path("test_rules.json")
        if test_file.exists():
            test_file.unlink()
    
    return True


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)