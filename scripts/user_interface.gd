extends CanvasLayer

@onready var dialogue = $Dialogue

func _on_SaveButton_pressed():
	dialogue.save_to_file("user://save1.json")

func _on_LoadButton_pressed():
	dialogue.load_from_file("user://save1.json")
