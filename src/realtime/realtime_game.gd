extends Node2D
## ???????????????????Arena(z=-30) < EntitiesYSort(z=0) < FxLayer(z=15) ???
## ?? HUD ? CanvasLayer(layer=100)?????????????

const _Wx := preload("res://src/realtime/realtime_wuxing.gd")
const _Stance := preload("res://src/realtime/realtime_stance_defs.gd")
const _MonsterData := preload("res://src/realtime/realtime_monster_data.gd")

const MAP_W_TILES := 40
const MAP_H_TILES := 25
const TILE_PX := 16

const ENEMY_SCENE := preload("res://scenes/realtime/realtime_enemy.tscn")
const ENEMY_COUNT := 14

const _FONT: Font = preload("res://assets/fonts/pixel_operator/PixelOperatorSC.ttf")
const _FLOAT_SCRIPT: GDScript = preload("res://src/realtime/realtime_floating_damage.gd")

@onready var player: CharacterBody2D = $EntitiesYSort/Player
@onready var enemies_container: Node2D = $EntitiesYSort/EnemiesContainer
@onready var fx_layer: Node2D = $FxLayer
@onready var hp_label: Label = $HUDLayer/Panel/VBox/HPLabel
@onready var hint_label: Label = $HUDLayer/Panel/VBox/HintLabel
@onready var vbox: VBoxContainer = $HUDLayer/Panel/VBox

var _lbl_element: Label
var _lbl_branch: Label
var _lbl_return_cd: Label
var _lbl_rage: Label
var _lbl_weapon: Label
var _icon_row: HBoxContainer
var _pb_hp: Range
var _pb_rage: Range
var _pb_recall: Range
var _pb_shield: Range


func _ready() -> void:
	Engine.max_fps = 60
	add_to_group("realtime_game_root")
	_build_resource_bars()
	_build_wuxing_hud()
	_apply_cjk_font_to_hud()
	_spawn_enemies()
	_spawn_training_dummies()
	for e in enemies_container.get_children():
		if e.has_method("set_target"):
			e.call("set_target", player)
	if hint_label:
		hint_label.text = "WASD | LMB | RMB | Space dodge | R recall | F rage | Tab | Z"


func spawn_damage_float(world_pos: Vector2, amount: int, color: Color) -> void:
	if fx_layer == null:
		return
	var fx := Node2D.new()
	fx.set_script(_FLOAT_SCRIPT)
	fx_layer.add_child(fx)
	fx.global_position = world_pos
	fx.call("setup", amount, color)


func spawn_heal_float(world_pos: Vector2, amount: int) -> void:
	if fx_layer == null:
		return
	var fx := Node2D.new()
	fx.set_script(_FLOAT_SCRIPT)
	fx_layer.add_child(fx)
	fx.global_position = world_pos
	fx.call("setup_heal", amount)


func _try_load_tex(path: String) -> Texture2D:
	# ????? PNG ?????????????????? ERROR
	if String(DisplayServer.get_name()).to_lower() == "headless":
		return null
	var t: Variant = load(path)
	return t as Texture2D


func _build_resource_bars() -> void:
	var hp_bg: Texture2D = _try_load_tex("res://assets/realtime/ui/hud/bar_hp_bg.png")
	var hp_fill: Texture2D = _try_load_tex("res://assets/realtime/ui/hud/bar_hp_fill.png")
	var rage_bg: Texture2D = _try_load_tex("res://assets/realtime/ui/hud/bar_rage_bg.png")
	var rage_fill: Texture2D = _try_load_tex("res://assets/realtime/ui/hud/bar_rage_fill.png")
	var cd_bg: Texture2D = _try_load_tex("res://assets/realtime/ui/hud/bar_return_cd_bg.png")
	var cd_fill: Texture2D = _try_load_tex("res://assets/realtime/ui/hud/bar_return_cd_fill.png")
	var sh_bg: Texture2D = _try_load_tex("res://assets/realtime/ui/hud/bar_shield_bg.png")
	var sh_fill: Texture2D = _try_load_tex("res://assets/realtime/ui/hud/bar_shield_fill.png")

	if hp_bg != null and hp_fill != null:
		_pb_hp = _make_tex_progress(hp_bg, hp_fill, 168, 14)
	else:
		_pb_hp = _make_flat_progress(168, 14, Color(0.78, 0.24, 0.22))
	_pb_hp.name = "PlayerHpBar"
	_pb_hp.max_value = 100.0
	vbox.add_child(_make_bar_row("HP", _pb_hp as Control))

	if sh_bg != null and sh_fill != null:
		_pb_shield = _make_tex_progress(sh_bg, sh_fill, 140, 10)
	else:
		_pb_shield = _make_flat_progress(140, 10, Color(0.45, 0.75, 0.95))
	_pb_shield.name = "PlayerShieldBar"
	_pb_shield.max_value = 50.0
	_pb_shield.visible = false
	vbox.add_child(_make_bar_row("Shield", _pb_shield as Control))

	if rage_bg != null and rage_fill != null:
		_pb_rage = _make_tex_progress(rage_bg, rage_fill, 168, 12)
	else:
		_pb_rage = _make_flat_progress(168, 12, Color(0.88, 0.72, 0.28))
	_pb_rage.name = "PlayerRageBar"
	_pb_rage.max_value = 100.0
	vbox.add_child(_make_bar_row("Rage", _pb_rage as Control))

	if cd_bg != null and cd_fill != null:
		_pb_recall = _make_tex_progress(cd_bg, cd_fill, 140, 10)
	else:
		_pb_recall = _make_flat_progress(140, 10, Color(0.38, 0.62, 0.92))
	_pb_recall.name = "RecallCdBar"
	_pb_recall.max_value = 100.0
	vbox.add_child(_make_bar_row("Recall", _pb_recall as Control))


func _make_tex_progress(under: Texture2D, over: Texture2D, w: int, h: int) -> TextureProgressBar:
	var p := TextureProgressBar.new()
	p.custom_minimum_size = Vector2(w, h)
	p.texture_under = under
	p.texture_progress = over
	p.min_value = 0.0
	p.max_value = 100.0
	p.value = 100.0
	return p


func _make_flat_progress(w: int, h: int, fill: Color) -> ProgressBar:
	var pb := ProgressBar.new()
	pb.custom_minimum_size = Vector2(w, h)
	pb.show_percentage = false
	var sb_bg := StyleBoxFlat.new()
	sb_bg.bg_color = Color(0.13, 0.13, 0.16)
	sb_bg.set_border_width_all(1)
	sb_bg.border_color = Color(0.38, 0.4, 0.45)
	var sb_fill := StyleBoxFlat.new()
	sb_fill.bg_color = fill
	pb.add_theme_stylebox_override("background", sb_bg)
	pb.add_theme_stylebox_override("fill", sb_fill)
	pb.min_value = 0.0
	pb.max_value = 100.0
	pb.value = 100.0
	return pb


func _make_bar_row(title: String, bar: Control) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	var lab := Label.new()
	lab.text = title
	lab.custom_minimum_size = Vector2(36, 0)
	lab.add_theme_font_override("font", _FONT)
	lab.add_theme_font_size_override("font_size", 11)
	row.add_child(lab)
	row.add_child(bar)
	return row


func _apply_cjk_font_to_hud() -> void:
	var f: Font = _FONT
	_font_override_recursive(vbox, f)
	if hp_label:
		hp_label.add_theme_font_override("font", f)
	if hint_label:
		hint_label.add_theme_font_override("font", f)


func _font_override_recursive(ctrl: Control, f: Font) -> void:
	if ctrl is Label:
		(ctrl as Label).add_theme_font_override("font", f)
	for ch in ctrl.get_children():
		if ch is Control:
			_font_override_recursive(ch as Control, f)


func _build_wuxing_hud() -> void:
	_lbl_element = Label.new()
	_lbl_element.name = "ElementLabel"
	vbox.add_child(_lbl_element)

	_lbl_branch = Label.new()
	_lbl_branch.name = "BranchLabel"
	vbox.add_child(_lbl_branch)

	_lbl_weapon = Label.new()
	_lbl_weapon.name = "WeaponLabel"
	vbox.add_child(_lbl_weapon)

	_icon_row = HBoxContainer.new()
	_icon_row.name = "WuxingIconRow"
	_icon_row.add_theme_constant_override("separation", 4)
	vbox.add_child(_icon_row)

	var names: PackedStringArray = ["metal", "wood", "water", "fire", "earth"]
	for i in 5:
		var tr := TextureRect.new()
		tr.custom_minimum_size = Vector2(22, 22)
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var path := "res://assets/realtime/ui/icon_%s.png" % names[i]
		if ResourceLoader.exists(path):
			tr.texture = load(path)
		else:
			var col: Color = _Wx.element_color(_Wx.element_from_index(i))
			tr.modulate = col
			var img := Image.create(22, 22, false, Image.FORMAT_RGBA8)
			img.fill(Color(col.r, col.g, col.b, 0.85))
			tr.texture = ImageTexture.create_from_image(img)
		_icon_row.add_child(tr)

	_lbl_return_cd = Label.new()
	_lbl_return_cd.name = "ReturnCdLabel"
	vbox.add_child(_lbl_return_cd)

	_lbl_rage = Label.new()
	_lbl_rage.name = "RageLabel"
	vbox.add_child(_lbl_rage)


func _spawn_enemies() -> void:
	var table: Array = _MonsterData.load_table()
	if table.is_empty():
		push_error("realtime_monsters.json empty")
		return
	var normal: Array = []
	for item: Variant in table:
		if str(item.id).begins_with("dummy_"):
			continue
		normal.append(item)
	if normal.is_empty():
		normal = table
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var center := Vector2(MAP_W_TILES * 0.5 * TILE_PX, MAP_H_TILES * 0.5 * TILE_PX)
	var margin := float(TILE_PX * 3)
	var max_x := float(MAP_W_TILES * TILE_PX) - margin
	var max_y := float(MAP_H_TILES * TILE_PX) - margin
	for i in ENEMY_COUNT:
		var e: CharacterBody2D = ENEMY_SCENE.instantiate() as CharacterBody2D
		var data: Variant = normal[i % normal.size()]
		e.set("monster_data", data)
		var angle := rng.randf() * TAU
		var rad := rng.randf_range(130.0, 270.0)
		var pos := center + Vector2(cos(angle), sin(angle)) * rad
		pos.x = clampf(pos.x, margin, max_x)
		pos.y = clampf(pos.y, margin, max_y)
		e.position = pos
		enemies_container.add_child(e)


func _spawn_training_dummies() -> void:
	var table: Array = _MonsterData.load_table()
	var dummies: Array = []
	for item: Variant in table:
		if str(item.id).begins_with("dummy_"):
			dummies.append(item)
	var offsets: Array[Vector2] = [
		Vector2(120, 210),
		Vector2(168, 210),
		Vector2(216, 210),
		Vector2(264, 210),
		Vector2(312, 210),
	]
	for i in mini(dummies.size(), offsets.size()):
		var e: CharacterBody2D = ENEMY_SCENE.instantiate() as CharacterBody2D
		e.set("monster_data", dummies[i])
		e.set("is_training_dummy", true)
		e.position = offsets[i]
		enemies_container.add_child(e)


func _process(_delta: float) -> void:
	if hp_label:
		var alive := get_tree().get_nodes_in_group("realtime_enemy").size()
		hp_label.text = "??: %d" % alive

	if player == null:
		return
	var wx: _Wx.Element = player.get("current_element") as _Wx.Element
	var br: _Stance.Branch = player.get("current_branch") as _Stance.Branch
	var row: Dictionary = _Stance.row(wx, br)
	if _lbl_element:
		_lbl_element.text = "??: %s" % _Wx.element_name_cn(wx)
	if _lbl_branch:
		_lbl_branch.text = "??: %s" % str(row.get("branch_name_cn", ""))
	if _lbl_weapon:
		var br_txt := "??" if br == _Stance.Branch.REMOTE else "??"
		_lbl_weapon.text = "??: %s" % br_txt

	var cd_ret: float = float(player.get("cd_return"))
	var rage: int = int(player.get("rage"))
	const PLAYER_RAGE_MAX := 100
	var p_hp: int = int(player.get("hp"))
	var p_max: int = int(player.get("max_hp"))
	var sh: int = int(player.get("shield_hp"))

	if _pb_hp:
		_pb_hp.max_value = float(maxi(1, p_max))
		_pb_hp.value = float(p_hp)

	if _pb_shield:
		_pb_shield.visible = sh > 0
		if sh > 0:
			_pb_shield.value = float(sh)

	if _pb_rage:
		_pb_rage.value = float(rage)

	var cd_max: float = float(row.get("return_cd", 2.0))
	if _pb_recall:
		if cd_ret <= 0.0:
			_pb_recall.value = 100.0
		else:
			_pb_recall.value = (1.0 - clampf(cd_ret / maxf(cd_max, 0.05), 0.0, 1.0)) * 100.0

	var ret_txt: String = ("?? %.1fs" % cd_ret) if cd_ret > 0.0 else "????"
	if _lbl_return_cd:
		_lbl_return_cd.text = "%s | ???? %.0f / ???? %.0f" % [
			ret_txt,
			float(row.get("return_radius", 0.0)),
			float(row.get("rage_radius", 0.0)),
		]
	if _lbl_rage:
		_lbl_rage.text = "?? %d / %d?F?" % [rage, PLAYER_RAGE_MAX]

	if hint_label:
		hint_label.text = "%s | WASD | Space ?? | R ?? | F ? | Tab | Z" % ret_txt
