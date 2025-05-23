extends CanvasLayer

@onready var game = $".."

func _on_SaveButton_pressed():
	game.save_to_file("user://save1.json")

func _on_LoadButton_pressed():
	game.load_from_file("user://save1.json")
