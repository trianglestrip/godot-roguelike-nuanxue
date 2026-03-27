extends Node
## Headless tests for phase C (action combat / hitboxes).

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
	var player: Node = root.get_node_or_null("EntitiesYSort/Player")
	var ok: bool = player != null and player.has_node("MeleeHitbox")
	root.queue_free()
	return 0 if ok else 1
