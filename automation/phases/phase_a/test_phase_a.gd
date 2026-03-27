extends Node
## Headless tests for phase A (realtime loop skeleton).

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
	if not ProjectSettings.get_setting("gameplay/realtime_enabled", false):
		push_error("gameplay/realtime_enabled missing or false")
		return 1
	if not ResourceLoader.exists("res://scenes/realtime/realtime_game.tscn"):
		push_error("realtime_game.tscn missing")
		return 1
	return 0
