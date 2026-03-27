extends Node
## Headless tests for phase E (camera / HUD polish, no wuxing).

func _ready() -> void:
	var code := _run()
	print("HEADLESS_TEST_EXIT_CODE=", code)
	call_deferred("_quit", code)


func _quit(code: int) -> void:
	get_tree().quit(code)


func _run() -> int:
	var sc: PackedScene = load("res://scenes/realtime/realtime_game.tscn") as PackedScene
	if sc == null:
		return 1
	var root: Node = sc.instantiate()
	var cam: Node = root.find_child("Camera2D", true, false)
	var hud: Node = root.find_child("HUDLayer", true, false)
	root.queue_free()
	if cam == null or hud == null:
		return 1
	return 0
