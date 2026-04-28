# 需求文档

## 简介

快递单号自动识别填充工具是一个桌面应用程序，用于自动识别Excel模板中的快递运单号并填充对应的快递公司编码。该工具通过维护本地运单号规则库，根据中国快递运单号规则自动识别快递公司，提高数据录入效率和准确性。

## 术语表

- **Application**: 快递单号自动识别填充工具桌面应用程序
- **Excel_Template**: 包含订单编号、物流公司、运单号三列的第一个工作表，以及快递公司名称列表的第二个工作表的Excel文件
- **Tracking_Number**: 快递运单号，用于标识快递包裹的唯一编号
- **Courier_Code**: 快递公司编码，用于标识快递公司的代码
- **Rule_Database**: 本地维护的运单号识别规则库，包含各快递公司的运单号格式规则
- **Order_Sheet**: Excel模板的第一个工作表，包含订单编号、物流公司、运单号三列
- **Courier_List_Sheet**: Excel模板的第二个工作表，包含快递公司名称列表
- **Recognition_Engine**: 运单号识别引擎，根据规则库识别运单号所属快递公司

## 需求

### 需求 1: 文件选择

**用户故事:** 作为用户，我希望能够选择要处理的Excel文件，以便程序能够读取和处理模板数据。

#### 验收标准

1. WHEN THE Application 启动时, THE Application SHALL 显示文件选择对话框
2. THE Application SHALL 支持选择扩展名为.xlsx和.xls的Excel文件
3. WHEN 用户取消文件选择时, THE Application SHALL 退出程序
4. WHEN 用户选择文件后, THE Application SHALL 验证文件是否可读取

### 需求 2: Excel模板验证

**用户故事:** 作为用户，我希望程序能够验证选择的Excel文件是否符合模板格式，以便避免处理错误格式的文件。

#### 验收标准

1. WHEN 文件被选择后, THE Application SHALL 验证Excel文件至少包含2个工作表
2. THE Application SHALL 使用模糊匹配方式验证第一个工作表包含"订单编号"、"物流公司"、"运单号"关键字的列名
3. THE Application SHALL 接受列名包含关键字的格式（如"物流公司（请填写物流公司编码）"匹配"物流公司"关键字）
4. THE Application SHALL 验证第二个工作表包含快递公司名称列表
5. IF 文件格式不符合模板要求, THEN THE Application SHALL 显示错误消息并提示用户重新选择文件
6. WHEN 模板验证通过后, THE Application SHALL 继续执行识别流程

### 需求 3: 运单号读取

**用户故事:** 作为用户，我希望程序能够读取Excel模板中的运单号数据，以便进行快递公司识别。

#### 验收标准

1. WHEN 模板验证通过后, THE Application SHALL 读取Order_Sheet中所有行的运单号列数据
2. THE Application SHALL 跳过空白运单号单元格
3. THE Application SHALL 去除运单号前后的空白字符
4. WHEN 读取完成后, THE Application SHALL 记录读取的运单号总数

### 需求 4: 运单号识别

**用户故事:** 作为用户，我希望程序能够根据运单号规则自动识别快递公司，以便自动填充快递公司编码。

#### 验收标准

1. WHEN 运单号被读取后, THE Recognition_Engine SHALL 根据Rule_Database中的规则匹配运单号
2. THE Recognition_Engine SHALL 按照规则优先级顺序进行匹配
3. WHEN 运单号匹配成功时, THE Recognition_Engine SHALL 返回对应的Courier_Code
4. IF 运单号无法匹配任何规则, THEN THE Recognition_Engine SHALL 标记该运单号为未识别状态
5. THE Recognition_Engine SHALL 支持基于正则表达式的运单号格式匹配

### 需求 5: 快递公司编码填充

**用户故事:** 作为用户，我希望程序能够将识别出的快递公司编码自动填充到Excel模板中，以便完成数据处理。

#### 验收标准

1. WHEN 运单号识别完成后, THE Application SHALL 将Courier_Code写入Order_Sheet对应行的"物流公司"列
2. THE Application SHALL 保持原有的订单编号和运单号数据不变
3. WHEN 运单号未识别时, THE Application SHALL 在"物流公司"列填充"未识别"标记
4. WHEN 所有数据填充完成后, THE Application SHALL 保存Excel文件
5. THE Application SHALL 保存文件到原文件路径

### 需求 6: 规则库维护

**用户故事:** 作为用户，我希望能够维护和修改运单号识别规则，以便适应新的快递公司或规则变化。

#### 验收标准

1. THE Application SHALL 在本地存储Rule_Database文件
2. THE Rule_Database SHALL 使用JSON或XML格式存储规则数据
3. THE Rule_Database SHALL 包含快递公司名称、Courier_Code、运单号正则表达式、优先级字段
4. WHEN Application首次运行时, THE Application SHALL 读取Excel_Template的Courier_List_Sheet并生成包含这些快递公司的初版Rule_Database
5. THE Application SHALL 为初版Rule_Database中的每个快递公司配置对应的运单号识别规则（基于中国常见快递公司运单号格式）
6. WHEN Rule_Database文件已存在时, THE Application SHALL 加载现有规则库而不覆盖
7. THE Application SHALL 提供规则库文件的访问路径说明
8. WHEN Rule_Database文件格式错误时, THE Application SHALL 显示错误消息并重新生成默认规则库

### 需求 7: 处理结果反馈

**用户故事:** 作为用户，我希望程序能够显示处理结果统计，以便了解识别和填充的执行情况。

#### 验收标准

1. WHEN 处理完成后, THE Application SHALL 显示处理结果对话框
2. THE Application SHALL 显示总运单号数量
3. THE Application SHALL 显示成功识别的运单号数量
4. THE Application SHALL 显示未识别的运单号数量
5. THE Application SHALL 显示文件保存路径
6. WHEN 用户确认结果后, THE Application SHALL 退出程序

### 需求 8: 错误处理

**用户故事:** 作为用户，我希望程序能够妥善处理各种错误情况，以便在出现问题时获得清晰的提示。

#### 验收标准

1. IF Excel文件被其他程序占用, THEN THE Application SHALL 显示文件占用错误消息
2. IF Excel文件读取失败, THEN THE Application SHALL 显示读取错误消息并退出
3. IF Excel文件保存失败, THEN THE Application SHALL 显示保存错误消息并保留原文件
4. IF Rule_Database加载失败, THEN THE Application SHALL 显示警告消息并使用默认规则库继续执行
5. WHEN 发生未预期错误时, THE Application SHALL 记录错误日志并显示通用错误消息

### 需求 9: 用户界面

**用户故事:** 作为用户，我希望程序具有简洁友好的用户界面，以便轻松使用该工具。

#### 验收标准

1. THE Application SHALL 使用Windows原生对话框进行文件选择
2. THE Application SHALL 在处理过程中显示进度指示器
3. THE Application SHALL 使用消息框显示错误和结果信息
4. THE Application SHALL 支持中文界面显示
5. WHEN 处理时间超过2秒时, THE Application SHALL 显示处理进度百分比

### 需求 10: 性能要求

**用户故事:** 作为用户，我希望程序能够快速处理Excel文件，以便提高工作效率。

#### 验收标准

1. WHEN 处理包含1000行数据的Excel文件时, THE Application SHALL 在10秒内完成识别和填充
2. THE Application SHALL 在启动后3秒内显示文件选择对话框
3. THE Rule_Database SHALL 在应用启动时加载到内存中
4. THE Application SHALL 使用批量写入方式更新Excel文件以提高性能
