extends Node2D

var BG_TEXTURES = {
	# 占位
	"dormitory" : preload("res://assets/pictures/backgrounds/dormitory.png"),
	"club classroom" : preload("res://assets/pictures/backgrounds/club_classroom.png"),
	"library" : preload("res://assets/pictures/backgrounds/library_1.png"),
	"library2" : preload("res://assets/pictures/backgrounds/library_2.png"),
	"library warehouse" : preload("res://assets/pictures/backgrounds/library_warehouse.png"),
	#"classroom1" : preload(),
	"classroom2" : preload("res://assets/pictures/backgrounds/classroom_2.png"),
	"office" : preload("res://assets/pictures/backgrounds/office.png"),
	"piano room" : preload("res://assets/pictures/backgrounds/piano_room.png"),
	"balcony1" : preload("res://assets/pictures/backgrounds/balcony_1.png"),
	"balcony2" : preload("res://assets/pictures/backgrounds/balcony_2.png"),
	"lockers" : preload("res://assets/pictures/backgrounds/lockers_1.png"),
	"lockers2" : preload("res://assets/pictures/backgrounds/lockers_2.png"),
	"basement" : preload("res://assets/pictures/backgrounds/basement.png"),
	"bed" : preload("res://assets/pictures/backgrounds/bed.png"),
	"biological laboratory" : preload("res://assets/pictures/backgrounds/biological_laboratory.png"),
	"biological laboratory2" : preload("res://assets/pictures/backgrounds/biological_laboratory_2.png"),
	"bench" : preload("res://assets/pictures/backgrounds/bench.png")
	
}
	
var CHARACTER_TEXTURES = {
	"LinYe" : preload("res://assets/pictures/characters/LinYe.png"),
	"ChenHao" : preload("res://assets/pictures/characters/ChenHao.png"),
	"XiaoYu" : preload("res://assets/pictures/characters/XiaoYu.png"),
	"ZhangYi" : preload("res://assets/pictures/characters/ZhangYi.png"),
	"professor" : preload("res://assets/pictures/characters/professor.png"),
	"ChenMo" : preload("res://assets/pictures/characters/ChenMo.png")
}

# 存放已经实例化的角色节点，key = 角色名
var character_nodes: Dictionary = {}
# 存放当前背景的 key
# 依据实际初始场景设置初始值
var bg_current_name : String = "dormitory";

@onready var bg_current = $BgCurrent
@onready var bg_next    = $BgNext
@onready var dialogue = $UserInterface/Dialogue
@onready var characters_container = $Characters
@onready var ink_story = dialogue.ink_story

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists("user://save1.json"):
		load_from_file("user://save1.json")
	emit_signal("ready")


func _on_dialogue_tag_parsed(key: String, value: String) -> void:
	match key:
		"background":
			_change_background_to(value)
		"character":
			# 支持两种用法：
			# 1) # character:knight  —— 添加/显示 knight
			# 2) # character:!knight —— 隐藏/移除 knight
			# 3) # character:!all    —— 清除所有角色
			if value.begins_with("!"):
				var name = value.substr(1)
				if name == "all":
					_clear_all_characters()
				else:
					_hide_character(name)
			else:
				_show_character(value)

var bg_fade_time = 1.0
var char_fade_time = 1.0

func _change_background_to(name: String) -> void:
	if not BG_TEXTURES.has(name):
		push_warning("Unknown background: %s" % name)
		return
	# 更新当前背景名称
	bg_current_name = name;
	# 1) 在 bg_next 上设置新纹理，并置于透明
	bg_next.texture       = BG_TEXTURES[name]
	bg_next.modulate.a    = 0.0

	# 2) 并行创建一个 Tween，同步控制两个节点
	var tween = create_tween()
	var tween2 = create_tween()
	# 淡出当前背景
	tween.tween_property(bg_current, "modulate:a", 0.0, bg_fade_time)
	# 同时淡入新背景（starts immediately）
	tween2.tween_property(bg_next,    "modulate:a", 1.0, bg_fade_time)

	 # 3) tween 完成后，交换节点引用：新背景变成 current
	var cb = Callable(self, "_on_crossfade_complete").bind(name)
	tween.tween_callback(cb)

# 回调：交叉动画结束后，把 bg_next 变为 bg_current
func _on_crossfade_complete(name: String) -> void:
	# 1) 让旧节点指向当前显示的纹理
	bg_current.texture = bg_next.texture
	# 2) 重置透明度
	bg_current.modulate.a = 1.0
	bg_next.modulate.a    = 0.0

# 角色显示的统一框体大小
var char_display_size: Vector2 = Vector2(750, 900)  # 可按需调整宽高

# —— 显示（或切换/刷新）一个角色，带淡入动画与限位框
func _show_character(name: String) -> void:
	var tex = CHARACTER_TEXTURES.get(name, null)
	if tex == null:
		push_warning("Unknown character: %s" % name)
		return

	# 如果已存在，不操作
	if character_nodes.has(name):
		return

	# 创建节点，设置统一最小尺寸（限位框）
	var node = TextureRect.new()
	node.name = name
	node.texture = tex
	node.expand_mode = TextureRect.EXPAND_FIT_HEIGHT
	node.custom_minimum_size = char_display_size      # 限定框体大小(?)
	node.size_flags_horizontal = TextureRect.SIZE_SHRINK_BEGIN
	node.size_flags_vertical = TextureRect.SIZE_SHRINK_BEGIN
	# 拉伸模式：保持宽高比，居中
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	# 初始全透明，用于淡入
	node.modulate = Color(1,1,1,0)
	# 锚点全拉满，以便容器管理位置和大小
	node.anchor_left = 0.0
	node.anchor_top = 0.0
	node.anchor_right = 1.0
	node.anchor_bottom = 1.0

	# 添加到 HBoxContainer 中
	characters_container.add_child(node)
	character_nodes[name] = node

	# 淡入：alpha 0 → 1 over char_fade_time
	node.create_tween()\
		.tween_property(node, "modulate:a", 1.0, char_fade_time)

# 隐藏并移除一个角色，带淡出动画
func _hide_character(name: String) -> void:
	if character_nodes.has(name):
		var node = character_nodes[name]
		# 淡出：1→0 over 0.5 秒，结束后队列释放
		node.create_tween()\
			.tween_property(node, "modulate:a", 0.0, char_fade_time)\
			.connect("finished", Callable(node, "queue_free"))
		character_nodes.erase(name)

# 清除所有角色，统一淡出后移除
func _clear_all_characters() -> void:
	for name in character_nodes.keys():
		var node = character_nodes[name]
		# 淡出并释放
		node.create_tween()\
			.tween_property(node, "modulate:a", 0.0, char_fade_time)\
			.connect("finished", Callable(node, "queue_free"))
	character_nodes.clear()

func save_to_file(path: String) -> void:
	# ink_story.SaveStateFile(path)
	# 1) 导出 Ink 运行时状态为 JSON 字符串
	var ink_state = ink_story.SaveState()
	# 2) 获取当前背景标识
	var bg_key = bg_current_name
	# 3) 获取当前在场角色列表（keys）
	var chars = []
	for name in character_nodes.keys():
		chars.append(name)

	# 4) 组装存档字典
	var save_dict = {
		"ink": ink_state,
		"background": bg_key,
		"characters": chars
	}

	# 5) 转为 JSON 并写文件
	var json = JSON.stringify(save_dict)
	var file = FileAccess.open(path, FileAccess.ModeFlags.WRITE)
	if file:
		file.store_string(json)
		file.close()
		print("Game saved to %s" % path)
	else:
		push_error("Cannot open save file: %s" % path)

func load_from_file(path: String) -> void:
	#ink_story.LoadStateFile(path)
	# 1) 检查并打开文件
	if not FileAccess.file_exists(path):
		push_warning("Save file not found: %s" % path)
		return
	var file = FileAccess.open(path, FileAccess.ModeFlags.READ)
	if not file:
		push_error("Cannot open save file: %s" % path)
		return

	# 2) 解析 JSON
	var json_text: String = file.get_as_text()
	file.close()
	var save_dict : Dictionary = JSON.parse_string(json_text)
	if typeof(save_dict) != TYPE_DICTIONARY:
		push_error("Invalid save data format")
		return

	# 3) 恢复 Ink 状态
	var ink_json = save_dict.get("ink")
	if ink_json != "":
		ink_story.LoadState(ink_json)

	# 4) 先重置画面
	#    直接清空所有角色，不做动画
	for name in character_nodes.keys():
		character_nodes[name].queue_free()
	character_nodes.clear()

	# 5) 恢复背景
	var bg_name = save_dict.get("background")
	if BG_TEXTURES.has(bg_name):
		_change_background_to(bg_name)

	# 6) 恢复角色
	for name in save_dict.get("characters", []):
		_show_character(name)  # 使用你原来的带动画或 instant 版
		
	# 清理旧选项
	for child in dialogue.options_container.get_children():
		child.queue_free()
	
	dialogue._show_next_line(ink_story.GetCurrentText())
