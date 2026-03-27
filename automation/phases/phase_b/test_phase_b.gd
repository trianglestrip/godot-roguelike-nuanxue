extends Node
## Headless tests for phase B (continuous movement).

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
	var s: GDScript = load("res://src/realtime/realtime_player.gd") as GDScript
	if s == null or s.get_instance_base_type() != "CharacterBody2D":
		return 1
	var sc: PackedScene = load("res://scenes/realtime/realtime_game.tscn") as PackedScene
	if sc == null:
		return 1
	var root: Node = sc.instantiate()
	var player: Node = root.get_node_or_null("EntitiesYSort/Player")
	var ok: bool = player != null and player is CharacterBody2D
	root.queue_free()
	return 0 if ok else 1
