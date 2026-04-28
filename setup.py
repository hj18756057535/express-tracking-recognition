"""
快递单号自动识别填充工具安装脚本
"""

from setuptools import setup, find_packages

with open("requirements.txt", "r", encoding="utf-8") as f:
    requirements = [line.strip() for line in f if line.strip() and not line.startswith("#")]

setup(
    name="express-tracking-tool",
    version="1.0.0",
    description="快递单号自动识别填充工具",
    long_description="一个基于Python的桌面应用程序，用于自动识别Excel模板中的快递运单号并填充对应的快递公司编码。",
    author="Express Tracking Tool Team",
    python_requires=">=3.8",
    packages=find_packages(),
    install_requires=requirements,
    entry_points={
        "console_scripts": [
            "express-tracking-tool=express_tracking_tool.main:main",
        ],
    },
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: End Users/Desktop",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Operating System :: Microsoft :: Windows",
        "Topic :: Office/Business",
        "Topic :: Utilities",
    ],
)