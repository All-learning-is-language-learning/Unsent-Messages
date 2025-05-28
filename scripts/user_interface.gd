extends CanvasLayer

@onready var game = $".."
@onready var message = $"../MessageSystem"

func _on_SaveButton_pressed():
	game.save_to_file("user://save1.json")

func _on_LoadButton_pressed():
	game.load_from_file("user://save1.json")

func _on_MessageButton_pressed():
	game._switch_message_system()
	
