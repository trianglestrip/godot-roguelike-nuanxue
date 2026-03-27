extends Node
## Headless tests for phase D（实时 AI 占位：敌人脚本 + 预制体）

func _ready() -> void:
	var code := _run()
	print("HEADLESS_TEST_EXIT_CODE=", code)
	call_deferred("_quit", code)


func _quit(code: int) -> void:
	get_tree().quit(code)


func _run() -> int:
	var v: Dictionary = Engine.get_version_info()
	if int(v.major) < 4:
		return 1
	var s: GDScript = load("res://src/realtime/realtime_enemy.gd") as GDScript
	if s == null or s.get_instance_base_type() != "CharacterBody2D":
		return 1
	if not ResourceLoader.exists("res://scenes/realtime/realtime_enemy.tscn"):
		return 1
	var src: String = s.source_code
	if not src.contains("AGGRO_RADIUS") or not src.contains("set_target"):
		return 1
	return 0
