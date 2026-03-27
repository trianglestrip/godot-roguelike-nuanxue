extends Node
## 集成：地图格数、敌人数、精灵纹理、碰撞层掩码（需运行 2 帧以完成 _ready 链）

const _Stance := preload("res://src/realtime/realtime_stance_defs.gd")
const _Wx := preload("res://src/realtime/realtime_wuxing.gd")

func _ready() -> void:
	_run_async()


func _run_async() -> void:
	var code := await _checks()
	print("HEADLESS_TEST_EXIT_CODE=", code)
	get_tree().quit(code)


func _checks() -> int:
	if str(ProjectSettings.get_setting("application/run/main_scene")) != "res://scenes/realtime/realtime_game.tscn":
		return 1
	var rm: Dictionary = _Stance.row(_Wx.Element.METAL, _Stance.Branch.REMOTE)
	if str(rm.get("branch_name_cn", "")) != "锐金流":
		return 1
	if float(rm.get("right_pierce_def", -1.0)) != 0.5:
		return 1

	var sc: PackedScene = load("res://scenes/realtime/realtime_game.tscn") as PackedScene
	if sc == null:
		return 1
	var root: Node = sc.instantiate()
	add_child(root)
	await get_tree().process_frame
	await get_tree().process_frame

	var tile_sprites: Node = root.find_child("TileSprites", true, false)
	if tile_sprites == null or tile_sprites.get_child_count() < 900:
		root.queue_free()
		return 1

	var enemies: Array[Node] = get_tree().get_nodes_in_group("realtime_enemy")
	if enemies.size() < 10:
		root.queue_free()
		return 1

	var player: CharacterBody2D = root.find_child("Player", true, false) as CharacterBody2D
	if player == null:
		root.queue_free()
		return 1

	var vs: Node = player.find_child("VisualSprite", true, false)
	if vs == null or not (vs is Sprite2D):
		root.queue_free()
		return 1
	if (vs as Sprite2D).texture == null:
		root.queue_free()
		return 1

	for e: Node in enemies:
		var ev: Node = e.find_child("VisualSprite", true, false)
		if ev == null or not (ev is Sprite2D) or (ev as Sprite2D).texture == null:
			root.queue_free()
			return 1

	if player.collision_layer != 1:
		root.queue_free()
		return 1
	if player.collision_mask != (2 | 4):
		root.queue_free()
		return 1

	var melee: Area2D = player.find_child("MeleeHitbox", true, false) as Area2D
	if melee == null or melee.collision_mask != 16:
		root.queue_free()
		return 1

	root.queue_free()
	return 0
