extends Control

# 根节点脚本：动态根据内容测算自身高度，并在父容器中正确排版

# --------------------------------------------------
# _ready() 初始化布局相关的 Size Flags
# --------------------------------------------------
func _ready():
	# 水平方向：展开并填充父容器宽度
	size_flags_horizontal = SIZE_EXPAND_FILL
	# 垂直方向：填充，但不均分（由 custom_minimum_size.y 决定高度）
	size_flags_vertical   = SIZE_FILL

# --------------------------------------------------
# set_data(author, content, time)
# 1. 设置文本内容到各个 Label
# 2. 等待一帧布局完成
# 3. 测算 PanelContainer 的最小高度
# 4. 加上内边距后写入 custom_minimum_size.y
# 5. 通知父容器 queue_sort() 重新排版
# --------------------------------------------------
func set_data(author: String, content: String, time: String) -> void:
	# 1) 将传入的数据写入到对应的 Label
	var header        = $PanelContainer/VBoxContainer/Header
	var author_label  = $PanelContainer/VBoxContainer/Header/AuthorLabel
	var time_label    = $PanelContainer/VBoxContainer/Header/TimeLabel
	var content_label = $PanelContainer/VBoxContainer/ContentLabel
	var panel         = $PanelContainer

	author_label.text  = author
	content_label.text = content
	time_label.text    = time  # 传入时可带空格或自行拼接
	self.text = "\n" + "\n" + content + "\n"

	# 2) 等待一帧，让 Godot 完成所有子控件的布局和尺寸计算
	await get_tree().process_frame

	# 5) 通知父 VBoxContainer 立即刷新布局
	var parent_container = get_parent()
	if parent_container:
		parent_container.queue_sort()
