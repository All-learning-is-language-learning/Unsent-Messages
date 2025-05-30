extends Control

# Message data
var messages = []
var visible_messages = []

# Game progress tracking
var game_progress = 5  # This will determine which messages are visible

# References to UI elements
@onready var message_list = $ScrollContainer/MessageList
@onready var back_button = $BackButton

# Preload the message item scene
var message_item_scene = preload("res://scenes/message_item.tscn") 

func _ready():
	# Connect back button signal
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Configure VBoxContainer spacing
	message_list.add_theme_constant_override("separation", 320)  # Add 10px spacing between items

	
	# Load messages from JSON
	load_messages()
	
	# Update visible messages based on current game progress
	update_visible_messages()
	
	# Populate the UI with visible messages
	populate_message_list()
	
	# Debug
	print("Message system ready")

func _input(event):
	# Check for Escape key to return to main game
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_on_back_button_pressed()

func load_messages():
	# Load message data from JSON file
	var file = FileAccess.open("res://assets/data/messages.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var error = json.parse(json_string)
		
		if error == OK:
			messages = json.data
			print("Loaded ", messages.size(), " messages")
		else:
			print("JSON Parse Error: ", json.get_error_message())
	else:
		print("Failed to open messages.json file")

func update_visible_messages():
	# Filter messages based on game progress
	visible_messages.clear()
	
	for message in messages:
		# Check if message should be visible based on progress
		if is_message_visible(message):
			# Add time if not present in the JSON
			if not message.has("time"):
				#message["time"] = "今天 14:30"  # Default time
				message["time"] = ""  # 不显示
			
			visible_messages.append(message)
	
	# Sort messages by id from highest to lowest (newest first)
	visible_messages.sort_custom(func(a, b): return a.id > b.id)
	
	print("Visible messages: ", visible_messages.size())

func is_message_visible(message):
	# Determine if a message is visible based on game progress
	if game_progress == 4:
		if message.id in [1, 2, 3, 4]:
			return true
		return false
		
	if game_progress == 5:
		if message.id in [1, 2, 3, 5]:
			return true
		return false
		
	# 随机展示
	if message.id >= 5 and message.id <= 30:
		# 以25%概率展示，可以根据需要调整概率
		return randi() % 4 == 0  # 25%概率
	return false

func populate_message_list():
	# Clear existing messages first
	for child in message_list.get_children():
		message_list.remove_child(child)
		child.queue_free()
	
	# Add each visible message to the UI
	for message in visible_messages:
		# Create the message item
		var message_item = message_item_scene.instantiate()
		
		# Make sure the message item has proper margins
		message_item.custom_minimum_size = Vector2(message_list.size.x, 0)  # Full width, auto height
		
		# Add to the list
		message_list.add_child(message_item)
		
		# Wait for the message_item to be properly added to the scene tree
		await get_tree().process_frame
		
		# Set message data - this will be called once the node is ready
		if message_item.has_method("set_data"):
			message_item.set_data(message.author, message.content, message.time if message.has("time") else "")
		else:
			push_error("Message item doesn't have set_data method")
	
	print("Populated message list with ", visible_messages.size(), " messages")

func _on_back_button_pressed():
	visible = !visible

# Public function to set the game progress and update visible messages
func set_game_progress(progress):
	game_progress = progress
	update_visible_messages()
	populate_message_list()
