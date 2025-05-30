extends Node2D

var BG_TEXTURES = {
	"dormitory" : preload("res://assets/pictures/backgrounds/dormitory.png"),
	"club classroom" : preload("res://assets/pictures/backgrounds/club_classroom.png"),
	"library" : preload("res://assets/pictures/backgrounds/library_1.png"),
	"library2" : preload("res://assets/pictures/backgrounds/library_2.png"),
	"library warehouse" : preload("res://assets/pictures/backgrounds/library_warehouse.png"),
	"classroom1" : preload("res://assets/pictures/backgrounds/classroom_1.png"),
	"classroom2" : preload("res://assets/pictures/backgrounds/classroom_2.png"),
	"office" : preload("res://assets/pictures/backgrounds/office.png"),
	"piano room" : preload("res://assets/pictures/backgrounds/piano_room.png"),
	"balcony1" : preload("res://assets/pictures/backgrounds/balcony_1.png"),
	"balcony2" : preload("res://assets/pictures/backgrounds/balcony_2.png"),
	"balcony bw" : preload("res://assets/pictures/backgrounds/balcony_black_and_white.png"),
	"lockers" : preload("res://assets/pictures/backgrounds/lockers_1.png"),
	"lockers2" : preload("res://assets/pictures/backgrounds/lockers_2.png"),
	"basement" : preload("res://assets/pictures/backgrounds/basement.png"),
	"bed" : preload("res://assets/pictures/backgrounds/bed.png"),
	"biological laboratory" : preload("res://assets/pictures/backgrounds/biological_laboratory.png"),
	"biological laboratory2" : preload("res://assets/pictures/backgrounds/biological_laboratory_2.png"),
	"bench" : preload("res://assets/pictures/backgrounds/bench.png"),
	"lianqin" : preload("res://assets/pictures/backgrounds/practice_piano.png"),
	"white smile" : preload("res://assets/pictures/backgrounds/white_smile.png"),
	"blue book" : preload("res://assets/pictures/backgrounds/blue_book.png"),
	"yunxi letter" : preload("res://assets/pictures/backgrounds/letter.png"),
	"hand bandage" : preload("res://assets/pictures/backgrounds/vc.png"),
	"same fingerprint" : preload("res://assets/pictures/backgrounds/fingerprint.png"),
	"fire" : preload("res://assets/pictures/backgrounds/fire.png"),
	"hurt neck" : preload("res://assets/pictures/backgrounds/hurt_neck.png"),
	"jiabao1" : preload("res://assets/pictures/backgrounds/violence_1.png"),
	"jiabao2" : preload("res://assets/pictures/backgrounds/violence_2.png"),
	"jiabao3" : preload("res://assets/pictures/backgrounds/violence_3.png"),
	"black" : preload("res://assets/pictures/backgrounds/black.png"),
	"xiangkuang" : preload("res://assets/pictures/backgrounds/album.png"),
	"baling" : preload("res://assets/pictures/backgrounds/baling.png"),
	"yaogao" : preload("res://assets/pictures/backgrounds/medicine.png"),
	"san" : preload("res://assets/pictures/backgrounds/umbrella.png"),
	"weixiexin" : preload("res://assets/pictures/backgrounds/weixiexin.png"),
	"stars" : preload("res://assets/pictures/backgrounds/stars.png"),
	"uniform" : preload("res://assets/pictures/backgrounds/uniform.png"),
	"computer1" : preload("res://assets/pictures/backgrounds/computer_1.png"),
	"computer2" : preload("res://assets/pictures/backgrounds/computer_2.png"),
	"pic" : preload("res://assets/pictures/backgrounds/pic.png"),
	"mirror" : preload("res://assets/pictures/backgrounds/mirror.png"),
	"note" : preload("res://assets/pictures/backgrounds/note.png"),
	"blood_star" : preload("res://assets/pictures/backgrounds/blood_star.png"),
	"scratch" : preload("res://assets/pictures/backgrounds/scratch.png"),
	"sad_medicine" : preload("res://assets/pictures/backgrounds/sad_medicine.png"),
	"perfume" : preload("res://assets/pictures/backgrounds/perfume.png"),
	"engraving" : preload("res://assets/pictures/backgrounds/engraving.png"),
	"live" : preload("res://assets/pictures/backgrounds/live.png")
	
}
	
var CHARACTER_TEXTURES = {
	"LinYe" : preload("res://assets/pictures/characters/LinYe.png"),
	"LinYe_shock" : preload("res://assets/pictures/characters/LinYeShock.png"),
	"LinYe_relieve" : preload("res://assets/pictures/characters/LinYeRelieve.png"),
	"LinYe_cry" : preload("res://assets/pictures/characters/LinYeCry.png"),
	"LinYe_sad" : preload("res://assets/pictures/characters/LinYeSad.png"),
	"ChenHao" : preload("res://assets/pictures/characters/ChenHao.png"),
	"XiaoYu" : preload("res://assets/pictures/characters/XiaoYu.png"),
	"XiaoYu_awkward" : preload("res://assets/pictures/characters/LinYeShock.png"),
	"XiaoYu_hesitant" : preload("res://assets/pictures/characters/LinYeRelieve.png"),
	"ZhangYi" : preload("res://assets/pictures/characters/ZhangYi.png"),
	"professor" : preload("res://assets/pictures/characters/professor.png"),
	"ChenMo" : preload("res://assets/pictures/characters/ChenMo.png"),
	"ASheng" : preload("res://assets/pictures/characters/ASheng.png")
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
@onready var camera = $Camera2D
@onready var memory_player = $UserInterface/MemoryPlayer
@onready var message_system = $MessageSystem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if FileAccess.file_exists("user://save1.json"):
		load_from_file("user://save1.json")
	emit_signal("ready")


func _on_dialogue_tag_parsed(tag: Array) -> void:
	match tag[0]:
		"background":
			_change_background_to(tag[1])
		"character":
			# 支持两种用法：
			# 1) # character:knight  —— 添加/显示 knight
			# 2) # character:!knight —— 隐藏/移除 knight
			# 3) # character:!all    —— 清除所有角色
			if tag[1].begins_with("!"):
				var name = tag[1].substr(1)
				if name == "all":
					_clear_all_characters()
				else:
					_hide_character(name)
			elif tag.size() == 3:
				_change_expression(tag[1], tag[2])
			else:
				_show_character(tag[1])
			
		"shake":
			camera.start_shake(2, 10)
		"memory":
			_on_memory_tag(tag[1])
		"state":
			message_system.set_game_progress(tag[1].to_int())
		"message":
			if(tag[1] == "open"):
				_open_message_system()
			elif(tag[1] == "close"):
				_close_message_system()

func _change_expression(name: String, expression: String):
	if !character_nodes.has(name):
		return
	var character = character_nodes.get(name)
	var tex = CHARACTER_TEXTURES.get(expression, null)
	character.texture = tex

# 当收到 memory 标签时调用
func _on_memory_tag(value: String) -> void:
	# value 格式: "dormitory,office,library"
	var keys = value.split(",", false)
	
	# 构造给 MemoryPlayer 的数组：第一个元素"memory"，后面是 Texture2D
	var mem_array: Array = ["memory"]
	for key in keys:
		if BG_TEXTURES.has(key):
			mem_array.append(BG_TEXTURES.get(key))
		else:
			push_warning("Unknown memory key: %s" % key)
	
	# 播放闪回序列，并等待它全部播完
	await memory_player.play_memory_sequence(mem_array)
	
	# 闪回结束后，继续对话流程（如果需要）
	#dialogue._continue_paragraph()

var bg_fade_time = 2.0
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
	node.mouse_filter = Control.MOUSE_FILTER_PASS

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
		"characters": chars,
		"state" : message_system.game_progress
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
	
	message_system.game_progress = save_dict.get("state")
	print("loaded game progress", message_system.game_progress)
	message_system.update_visible_messages()
	message_system.populate_message_list()
	
	# 清理旧选项
	for child in dialogue.options_container.get_children():
		child.queue_free()
	
	dialogue.next_button.visible = false
	
	dialogue._show_next_line(ink_story.GetCurrentText())

func _open_message_system():
	if(!message_system.visible):
		_switch_message_system()
		
func _close_message_system():
	if(message_system.visible):
		_switch_message_system()
	
func _switch_message_system():
	if(message_system.visible):
		message_system.visible = false
		for i in dialogue.get_children():
			i.position.x -= 450
			i.position.y += 550
		characters_container.position.x -= 450
		characters_container.scale.x = 1
		characters_container.scale.y = 1
	else :
		message_system.visible = true
		for i in dialogue.get_children():
			i.position.x += 450
			i.position.y -= 550
		characters_container.position.x += 450
		characters_container.scale.x = 0.6
		characters_container.scale.y = 0.6
