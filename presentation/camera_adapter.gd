extends Node
class_name CameraAdapter
## 仅订阅 EventBus，不引用 Domain；用于屏幕震动等反馈计数（后续可接 Phantom Camera）。

const _AutoloadAccess := preload("res://core/autoload_access.gd")

var shake_count: int = 0


func _ready() -> void:
	var eb: Node = _AutoloadAccess.event_bus()
	eb.connect("combat_hit", Callable(self, "_on_combat_hit"))


func _exit_tree() -> void:
	var eb: Node = _AutoloadAccess.event_bus()
	if eb.is_connected("combat_hit", Callable(self, "_on_combat_hit")):
		eb.disconnect("combat_hit", Callable(self, "_on_combat_hit"))


func _on_combat_hit(_data: Dictionary) -> void:
	shake_count += 1
