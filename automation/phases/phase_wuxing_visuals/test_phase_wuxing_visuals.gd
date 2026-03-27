extends Node
## 无头验收：五行立绘映射、攻击相位帧、神木近战 proj_speed、姿态收剑字段、子弹 configure。

const _Wx := preload("res://src/realtime/realtime_wuxing.gd")
const _Wvis := preload("res://src/realtime/realtime_wuxing_visuals.gd")
const _Stance := preload("res://src/realtime/realtime_stance_defs.gd")
const _FlyingSwordScene: PackedScene = preload("res://scenes/realtime/realtime_flying_sword.tscn")


func _ready() -> void:
	var code := await _run_async()
	print("HEADLESS_TEST_EXIT_CODE=", code)
	get_tree().quit(code)


func _run_async() -> int:
	for i in 5:
		var n: StringName = _Wvis.player_sprite_name(_Wx.element_from_index(i))
		var tex: Texture2D = CharacterTiles.get_texture(n) as Texture2D
		if tex == null:
			return 1

	if _Wvis.attack_frame_from_phase(-0.2) != 0:
		return 1
	if _Wvis.attack_frame_from_phase(0.0) != 0:
		return 1
	if _Wvis.attack_frame_from_phase(0.37) != 0:
		return 1
	if _Wvis.attack_frame_from_phase(0.38) != 1:
		return 1
	if _Wvis.attack_frame_from_phase(1.0) != 1:
		return 1

	if not _Wvis.should_emit_melee_swing(0.45, 0.1):
		return 1
	if _Wvis.should_emit_melee_swing(0.35, 0.1):
		return 1

	var wood_melee: Dictionary = _Stance.row(_Wx.Element.WOOD, _Stance.Branch.MELEE)
	if float(wood_melee.get("proj_speed", -99.0)) != 0.0:
		return 1

	for i in 5:
		var row: Dictionary = _Stance.row(_Wx.element_from_index(i), _Stance.Branch.REMOTE)
		if not row.has("return_vfx"):
			return 1
		if int(row.get("return_vfx", -1)) < 0:
			return 1

	var b: Area2D = _FlyingSwordScene.instantiate() as Area2D
	b.configure(Vector2(200, 0), 3, int(_Wx.Element.FIRE), 0.8, 0.25)
	add_child(b)
	await get_tree().process_frame
	await get_tree().process_frame
	if not is_instance_valid(b):
		return 1
	b.queue_free()
	return 0
