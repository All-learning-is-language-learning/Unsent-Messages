extends Control

signal tag_parsed

# —— 导出字段，让你在 Inspector 中关联已标记为主文件的 .ink 资源
@export var ink_story: InkStory

# —— 缓存对话文本容器（Label 或 RichTextLabel 节点）
@onready var text_container    = $Text
# —— 缓存选项按钮容器（VBoxContainer/HBoxContainer）
@onready var options_container = $Choices
# —— 缓存“下一句”按钮，用于逐行推进
@onready var next_button       = $NextButton

func _ready():
	# 场景加载完成后，立即开始第一段对话
	next_button.visible = false

func _start():
	_continue_paragraph()

# —— 读取新段落并初始化句子列表
func _continue_paragraph():
	# 清理旧选项
	for child in options_container.get_children():
		child.queue_free()
	next_button.visible = false

	if ink_story.GetCanContinue():
		# 1) 读取下一句
		var sentence: String = ink_story.call("Continue")

		# 3) 展示这句话
		_show_next_line(sentence)

func _show_next_line(sentence: String):
	# 2) 解析并发射这一句前的所有标签
	var tags = ink_story.call("GetCurrentTags")
	for t in tags:
		var parts = t.split(":")
		emit_signal("tag_parsed", parts)
	# 更新文本
	text_container.text = sentence
	# 开始打字动画
	var dur = calc_display_time(text_container.text.length())
	text_container.start_typewriter(dur)
	# 监听本句动画结束再决定下一步
	text_container.connect("typing_finished", Callable(self, "_on_line_typed"), CONNECT_ONE_SHOT)

# —— 信号回调：当“下一句”按钮被按下
func _on_NextButton_pressed():
	next_button.visible = false
	_continue_paragraph()

# —— 生成并显示所有 Ink 当前可选分支按钮
func _show_choices():
	# 每个 choice 对象都通过 GetText() / GetIndex() 访问其属性
	for choice in ink_story.call("GetCurrentChoices"):
		var btn = Button.new()
		btn.text = choice.call("GetText")
		
		# 自动换行模式
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		# 点击时，选择该分支并重新开始下一段逐行流程
		btn.pressed.connect(func():
			ink_story.call("ChooseChoiceIndex", choice.call("GetIndex"))
			_continue_paragraph()
		)
		options_container.add_child(btn)
		
		
func _on_line_typed():
	if ink_story.GetCanContinue():
		# 还没到最后一句，显示“下一句”
		next_button.visible = true
	else:
		next_button.visible = false
		# 最后一行打完，直接展示选项
		_show_choices()

# 根据句子长度计算动画时间
func calc_display_time(len: int) -> float:
	var T_min = 0.8
	var T_max = 2.0

	var L_max = 200
	# 对数映射
	var norm = 1.0 - (log(len + 1) / log(L_max + 1))
	var T = T_min + (T_max - T_min) * norm
	return T
