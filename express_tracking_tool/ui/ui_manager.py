"""
用户界面管理器
"""

import tkinter as tk
from tkinter import filedialog, messagebox
from typing import Optional


class UIManager:
    """用户界面管理器"""
    
    def __init__(self):
        """初始化UI管理器"""
        # 创建隐藏的根窗口
        self.root = tk.Tk()
        self.root.withdraw()  # 隐藏主窗口
        
        # 进度窗口相关
        self.progress_window = None
        self.progress_var = None
        self.progress_label = None
    
    def select_file(self) -> Optional[str]:
        """显示文件选择对话框
        
        Returns:
            选择的文件路径，取消返回None
        """
        file_path = filedialog.askopenfilename(
            title="选择Excel文件",
            filetypes=[
                ("Excel文件", "*.xlsx"),
                ("所有文件", "*.*")
            ]
        )
        
        return file_path if file_path else None
    
    def show_progress(self, current: int, total: int) -> None:
        """显示处理进度
        
        Args:
            current: 当前处理数量
            total: 总数量
        """
        if not self.progress_window:
            self._create_progress_window()
        
        if total > 0:
            percentage = int((current / total) * 100)
            self.progress_var.set(percentage)
            self.progress_label.config(text=f"正在处理... {current}/{total} ({percentage}%)")
        
        self.progress_window.update()
    
    def _create_progress_window(self):
        """创建进度窗口"""
        self.progress_window = tk.Toplevel(self.root)
        self.progress_window.title("处理进度")
        self.progress_window.geometry("300x100")
        self.progress_window.resizable(False, False)
        
        # 居中显示
        self.progress_window.transient(self.root)
        self.progress_window.grab_set()
        
        # 进度标签
        self.progress_label = tk.Label(
            self.progress_window, 
            text="正在处理...",
            font=("Arial", 10)
        )
        self.progress_label.pack(pady=10)
        
        # 进度条
        from tkinter import ttk
        self.progress_var = tk.IntVar()
        progress_bar = ttk.Progressbar(
            self.progress_window,
            variable=self.progress_var,
            maximum=100,
            length=250
        )
        progress_bar.pack(pady=10)
    
    def close_progress(self):
        """关闭进度窗口"""
        if self.progress_window:
            self.progress_window.destroy()
            self.progress_window = None
    
    def show_result(self, total: int, recognized: int, unrecognized: int, file_path: str) -> None:
        """显示处理结果
        
        Args:
            total: 总运单号数量
            recognized: 识别成功数量
            unrecognized: 未识别数量
            file_path: 文件保存路径
        """
        self.close_progress()
        
        message = f"""处理完成！

总运单号数量: {total}
识别成功: {recognized}
未识别: {unrecognized}
识别率: {(recognized/total*100):.1f}%

文件已保存到: {file_path}"""
        
        messagebox.showinfo("处理结果", message)
    
    def show_error(self, message: str) -> None:
        """显示错误消息
        
        Args:
            message: 错误消息
        """
        self.close_progress()
        messagebox.showerror("错误", message)
    
    def show_info(self, message: str) -> None:
        """显示信息消息
        
        Args:
            message: 信息消息
        """
        messagebox.showinfo("信息", message)
    
    def ask_yes_no(self, title: str, message: str) -> bool:
        """显示是否确认对话框
        
        Args:
            title: 对话框标题
            message: 消息内容
            
        Returns:
            用户选择结果
        """
        return messagebox.askyesno(title, message)
    
    def destroy(self):
        """销毁UI管理器"""
        if self.progress_window:
            self.progress_window.destroy()
        self.root.destroy()