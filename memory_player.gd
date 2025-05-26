extends Control

# 时长配置
var fade_time := 0.8    # 每张图的淡入/淡出时长
var stay_time := 1    # 每张图停留时间

# 播放一组记忆画面
# mem_array[0] == "memory"，后面 mem_array[1..] 为 Texture2D 资源
func play_memory_sequence(mem_array: Array) -> void:
	# 1) 确保这是一次回忆，且有贴图
	if mem_array.size() < 2 or mem_array[0] != "memory":
		return

	visible = true  # 显示蒙版
	var rect = $MemoryRect as TextureRect
	

	# 2) 按顺序播放每一张贴图
	for tex in mem_array.slice(1, mem_array.size()):
		if tex == null:
			continue

		# 设置贴图，重置透明度
		rect.texture = tex
		rect.modulate.a = 0

		# 淡入
		var tween_in = rect.create_tween()
		tween_in.tween_property(rect, "modulate:a", 1.0, fade_time)
		await tween_in.finished

		# 停留
		await get_tree().create_timer(stay_time).timeout

		# 淡出
		var tween_out = rect.create_tween()
		tween_out.tween_property(rect, "modulate:a", 0.0, fade_time)
		await tween_out.finished

	# 3) 全部播完后隐藏并清空贴图
	visible = false
	rect.texture = null
