extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible_ratio = 0.0
	pass # Replace with function body.

signal typing_finished

func start_typewriter(duration := 2.0):
	# 从 0% 到 100% 可见比例，持续时长由 duration 决定
	visible_ratio = 0.0
	var tween = create_tween()
	tween.tween_property(self, "visible_ratio", 1.0, duration).from(0.0)
	tween.connect("finished", Callable(self, "_on_typewriter_finished"))

func _on_typewriter_finished():
	emit_signal("typing_finished")
