extends Control

# Uncomment this to test the game immediately after running
# func _ready() -> void:
# 	call_deferred("_on_play_button_pressed")


func _on_play_button_pressed() -> void:
	# 即时制主流程（旧回合制 scenes/game/game.tscn 仍保留在仓库内供参考，未再接主菜单）
	get_tree().change_scene_to_file("res://scenes/realtime/realtime_game.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
