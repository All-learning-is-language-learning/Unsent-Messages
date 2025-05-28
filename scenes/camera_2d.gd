extends Camera2D

# 抖动持续总时长（秒）
var shake_time:   float = 0.0
# 抖动强度（像素幅度）
var shake_power:  float = 0.0
# 抖动衰减速度（秒⁻¹）
var shake_fade:   float = 1.0
# 原始位置缓存
var original_offset: Vector2

func _ready():
	# 记录初始 offset，用完恢复
	original_offset = offset

func _process(delta: float) -> void:
	if shake_time > 0.0:
		# 随机生成一个偏移向量
		var rand_x = (randf() * 2.0 - 1.0) * shake_power
		var rand_y = (randf() * 2.0 - 1.0) * shake_power
		offset = original_offset + Vector2(rand_x, rand_y)
		# 递减剩余时间与强度
		shake_time  -= delta
		shake_power -= shake_fade * delta
		# 强度不能为负
		if shake_power < 0.0:
			shake_power = 0.0
	else:
		# 抖动结束，恢复原点
		offset = original_offset

# 外部调用：开始一次抖动
func start_shake(duration: float, strength: float) -> void:
	shake_time  = duration
	shake_power = strength
	# 建议 fade 使强度线性衰减到 0
	shake_fade  = strength / duration
