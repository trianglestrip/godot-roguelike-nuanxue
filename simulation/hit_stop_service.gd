extends RefCounted
class_name HitStopService
## 单一入口管理命中停顿（避免各处直接改 Engine.time_scale）。


static var _depth: int = 0


static func push_hit_stop(scale: float = 0.08) -> void:
	_depth += 1
	Engine.time_scale = scale


static func pop_hit_stop() -> void:
	_depth = maxi(_depth - 1, 0)
	if _depth == 0:
		Engine.time_scale = 1.0


static func reset_for_tests() -> void:
	_depth = 0
	Engine.time_scale = 1.0
