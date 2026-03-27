extends Node
## 全局事件总线：跨模块只通过结构化 Dictionary 传递事实（与 docs/plan3 一致）。
## 载荷键名约定见各 signal 文档注释。

signal combat_hit(data: Dictionary)
signal enemy_killed(data: Dictionary)
signal player_dashed(data: Dictionary)


func emit_combat_hit(data: Dictionary) -> void:
	combat_hit.emit(data)


func emit_enemy_killed(data: Dictionary) -> void:
	enemy_killed.emit(data)


func emit_player_dashed(data: Dictionary) -> void:
	player_dashed.emit(data)
