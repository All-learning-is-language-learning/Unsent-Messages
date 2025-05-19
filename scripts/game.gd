extends Node2D

var bg_textures = {
	# 占位
	"a" : preload("res://assets/pictures/bg.png"),
	"b" : preload("res://assets/pictures/bg2.png")
}

var character_textures = {
	"pikachu": preload("res://assets/头像.jpg"),
	"aguo" : preload("res://assets/aguo.jpg")
}

# 存放已经实例化的角色节点，key = 角色名
var character_nodes: Dictionary = {}

@onready var bg_current = $BgCurrent
@onready var bg_next    = $BgNext
@onready var dialogue = $UserInterface/Dialogue
@onready var characters_container = $Characters

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists("user://save1.json"):
		dialogue.load_from_file("user://save1.json")
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
	if not bg_textures.has(name):
		return

	# 1) 在 bg_next 上设置新纹理，并置于透明
	bg_next.texture       = bg_textures[name]
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
var char_display_size: Vector2 = Vector2(400, 800)  # 可按需调整宽高

# —— 显示（或切换/刷新）一个角色，带淡入动画与限位框
func _show_character(name: String) -> void:
	var tex = character_textures.get(name, null)
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
