extends RefCounted
class_name DashController
## 无 Node：冲刺与无敌帧时间窗（供单元测试与 CharacterBody 驱动共用）。


var dash_time_left: float = 0.0
var invuln_time_left: float = 0.0


func process_delta(delta: float) -> void:
	dash_time_left = maxf(0.0, dash_time_left - delta)
	invuln_time_left = maxf(0.0, invuln_time_left - delta)


func start_dash(dash_duration_sec: float, invuln_duration_sec: float) -> void:
	dash_time_left = dash_duration_sec
	invuln_time_left = invuln_duration_sec


func is_dashing() -> bool:
	return dash_time_left > 0.0


func is_invulnerable() -> bool:
	return invuln_time_left > 0.0
