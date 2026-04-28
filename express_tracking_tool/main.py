"""
快递单号自动识别填充工具主程序入口
"""

import sys
from pathlib import Path

# 获取exe运行时的实际目录
# --onefile模式下 sys.executable 是exe本身路径，__file__ 是临时解压目录
if getattr(sys, 'frozen', False):
    # 打包后：所有文件读写都在exe所在目录
    APP_DIR = Path(sys.executable).parent
else:
    # 开发时：项目根目录
    APP_DIR = Path(__file__).parent.parent
    sys.path.insert(0, str(APP_DIR))

from express_tracking_tool.core.file_manager import FileManager
from express_tracking_tool.core.recognition_engine import RecognitionEngine
from express_tracking_tool.core.rule_manager import RuleManager
from express_tracking_tool.core.error_handler import ErrorHandler
from express_tracking_tool.ui.ui_manager import UIManager
from express_tracking_tool.config.settings import Settings
from express_tracking_tool.config.constants import UNRECOGNIZED_MARKER

# 初始化日志目录（必须在所有模块使用前设置）
ErrorHandler.setup(APP_DIR / "logs")


def main():
    """主程序入口"""
    ui_manager = None
    file_manager = None
    
    try:
        # 初始化设置，规则库路径指向exe同目录
        rule_db_path = str(APP_DIR / "data" / "courier_rules.json")
        settings = Settings()
        settings.set("rule_database_path", rule_db_path)
        
        # 初始化UI管理器
        ui_manager = UIManager()
        
        # 选择文件
        file_path = ui_manager.select_file()
        if not file_path:
            return  # 用户取消选择
        
        ErrorHandler.log_info(f"用户选择文件: {file_path}")
        
        # 初始化文件管理器
        file_manager = FileManager(file_path)
        
        # 验证模板格式
        is_valid, error_message = file_manager.validate_template()
        if not is_valid:
            ui_manager.show_error(f"文件格式验证失败：{error_message}")
            return
        
        ErrorHandler.log_info("文件格式验证通过")
        
        # 读取快递公司列表（名称+编码）
        courier_list = file_manager.read_courier_list()
        if not courier_list:
            ui_manager.show_error("未找到快递公司列表，请检查第二个工作表")
            return
        
        ErrorHandler.log_info(f"读取到 {len(courier_list)} 个快递公司")
        
        # 初始化规则管理器
        rule_manager = RuleManager(settings.rule_database_path)
        
        # 尝试加载现有规则库
        if not rule_manager.load_rules():
            # 生成默认规则库（使用sheet2的名称和编码）
            ErrorHandler.log_info("生成默认规则库")
            rule_manager.generate_default_rules(courier_list)
            rule_manager.save_rules()
            ui_manager.show_info(f"已生成默认规则库，保存到：{settings.rule_database_path}")
        else:
            ErrorHandler.log_info("加载现有规则库")
        
        # 初始化识别引擎
        recognition_engine = RecognitionEngine(rule_manager)
        
        # 读取运单号数据
        tracking_data = file_manager.read_tracking_numbers()
        if not tracking_data:
            ui_manager.show_error("未找到运单号数据，请检查Excel文件")
            return
        
        total_count = len(tracking_data)
        ErrorHandler.log_info(f"读取到 {total_count} 个运单号")
        
        # 处理运单号识别
        results = {}
        recognized_count = 0
        
        for i, (row_idx, tracking_number) in enumerate(tracking_data):
            # 更新进度
            if i % settings.progress_update_interval == 0 or i == total_count - 1:
                ui_manager.show_progress(i + 1, total_count)
            
            # 识别运单号
            courier_code = recognition_engine.recognize(tracking_number)
            
            if courier_code:
                results[row_idx] = courier_code
                recognized_count += 1
            else:
                results[row_idx] = UNRECOGNIZED_MARKER
        
        # 写入识别结果
        file_manager.write_courier_codes(results)
        file_manager.save()
        
        unrecognized_count = total_count - recognized_count
        
        ErrorHandler.log_info(f"处理完成：总数 {total_count}，识别 {recognized_count}，未识别 {unrecognized_count}")
        
        # 显示结果
        ui_manager.show_result(
            total=total_count,
            recognized=recognized_count,
            unrecognized=unrecognized_count,
            file_path=file_path
        )
        
    except Exception as e:
        error_message = ErrorHandler.handle_exception(e)
        if ui_manager:
            ui_manager.show_error(error_message)
        else:
            print(f"错误: {error_message}")
    
    finally:
        # 清理资源
        if file_manager:
            file_manager.close()
        if ui_manager:
            ui_manager.destroy()


if __name__ == "__main__":
    main()