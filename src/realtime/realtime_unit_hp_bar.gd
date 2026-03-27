extends Node2D
## 单位头顶血条（世界坐标，随实体移动）。子节点置于实体上层，z_index 应高于精灵。

const W := 28.0
const H := 4.0

var max_value: int = 1
var current: int = 1
var _fill_color := Color(0.92, 0.28, 0.28, 0.95)
var _track_color := Color(0.12, 0.12, 0.14, 0.88)


func _ready() -> void:
	z_index = 4


func set_values(cur: int, maximum: int, fill: Color = Color(0.92, 0.28, 0.28)) -> void:
	max_value = maxi(1, maximum)
	current = clampi(cur, 0, max_value)
	_fill_color = fill
	queue_redraw()


func _draw() -> void:
	var x0 := -W * 0.5
	draw_rect(Rect2(x0, 0.0, W, H), _track_color)
	var t: float = clampf(float(current) / float(max_value), 0.0, 1.0)
	if t > 0.0:
		draw_rect(Rect2(x0, 0.0, W * t, H), _fill_color)
	draw_rect(Rect2(x0, 0.0, W, H), Color(0.4, 0.42, 0.5, 0.9), false, 1.0)
