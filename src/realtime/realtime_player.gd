class_name RealtimePlayer
extends CharacterBody2D

const _Wx := preload("res://src/realtime/realtime_wuxing.gd")
const _Vfx := preload("res://src/realtime/realtime_skill_vfx.gd")
const _Stance := preload("res://src/realtime/realtime_stance_defs.gd")
const _Wvis := preload("res://src/realtime/realtime_wuxing_visuals.gd")
const _FlyingSwordScene: PackedScene = preload("res://scenes/realtime/realtime_flying_sword.tscn")
const MAX_FLYING_SWORDS := 7

const SPEED := 220.0
const DODGE_CD := 0.55
const DODGE_TIME := 0.18
const DODGE_SPEED := 460.0
const RAGE_MAX := 100
const RAGE_PER_HIT := 6

@onready var melee: Area2D = $MeleeHitbox

var current_element: _Wx.Element = _Wx.Element.METAL
var current_branch: _Stance.Branch = _Stance.Branch.REMOTE

var hp: int = 100
var max_hp: int = 100
var shield_hp: int = 0
var rage: int = 0

var cd_return: float = 0.0

var _aim: Vector2 = Vector2.RIGHT
var _attack_time := 0.0
var _attack_mode: String = ""
var _dodge_cd := 0.0
var _dodge_timer := 0.0
var _dodge_dir := Vector2.ZERO
var _lunge_timer := 0.0
var _lunge_vec := Vector2.ZERO
var _visual: Sprite2D
var _last_element: _Wx.Element = _Wx.Element.METAL
var _attack_total: float = 0.0
var _swing_emitted: bool = false
var _prev_attack_phase: float = 0.0


func _ready() -> void:
	collision_layer = 1
	collision_mask = 2 | 4
	melee.collision_mask = 16
	_register_actions()

	_visual = Sprite2D.new()
	_visual.name = "VisualSprite"
	_visual.texture = CharacterTiles.get_texture(&"player-4")
	_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual.centered = true
	_visual.hframes = CharacterTiles.FRAMES_PER_TILE
	_visual.position = Vector2(0, -4)
	add_child(_visual)
	_refresh_element_visual()
	_last_element = current_element


func _refresh_element_visual() -> void:
	if _visual == null:
		return
	_visual.texture = CharacterTiles.get_texture(_Wvis.player_sprite_name(current_element))
	_visual.modulate = _Wvis.sprite_tint(current_element)


func _register_actions() -> void:
	## 《暖雪》PC：空格瞬身、R 收剑；怒气大招用 F（不占 R）。
	if not InputMap.has_action("stance_dodge"):
		InputMap.add_action("stance_dodge")
	for keycode: Key in [KEY_SPACE, KEY_SHIFT]:
		if not _action_has_key("stance_dodge", keycode):
			var evd := InputEventKey.new()
			evd.physical_keycode = keycode
			InputMap.action_add_event("stance_dodge", evd)

	if not InputMap.has_action("recall_swords"):
		InputMap.add_action("recall_swords")
	if not _action_has_key("recall_swords", KEY_R):
		var evr := InputEventKey.new()
		evr.physical_keycode = KEY_R
		InputMap.action_add_event("recall_swords", evr)

	if not InputMap.has_action("rage_ult"):
		InputMap.add_action("rage_ult")
	if not _action_has_key("rage_ult", KEY_F):
		var evf := InputEventKey.new()
		evf.physical_keycode = KEY_F
		InputMap.action_add_event("rage_ult", evf)

	if not InputMap.has_action("toggle_branch"):
		InputMap.add_action("toggle_branch")
	var evz := InputEventKey.new()
	evz.physical_keycode = KEY_Z
	if not _action_has_key("toggle_branch", KEY_Z):
		InputMap.action_add_event("toggle_branch", evz)

	if not InputMap.has_action("attack_secondary"):
		InputMap.add_action("attack_secondary")
		var evm := InputEventMouseButton.new()
		evm.button_index = MOUSE_BUTTON_RIGHT
		InputMap.action_add_event("attack_secondary", evm)


func _action_has_key(action: String, keycode: Key) -> bool:
	if not InputMap.has_action(action):
		return false
	for ev: InputEvent in InputMap.action_get_events(action):
		if ev is InputEventKey and (ev as InputEventKey).physical_keycode == keycode:
			return true
	return false


func _stance() -> Dictionary:
	return _Stance.row(current_element, current_branch)


func _update_aim() -> void:
	var m := get_global_mouse_position() - global_position
	if m.length_squared() > 4.0:
		_aim = m.normalized()
	if _visual != null:
		_visual.flip_h = _aim.x < 0.0


func _get_game_root() -> Node2D:
	return get_parent().get_parent() as Node2D


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_TAB:
			var d: int = 1
			if event.shift_pressed:
				d = -1
			_cycle_element(d)
			get_viewport().set_input_as_handled()


func _cycle_element(delta_idx: int) -> void:
	var idx := int(current_element) + delta_idx
	idx = (idx % 5 + 5) % 5
	current_element = idx as _Wx.Element


func _attack_duration_for(style: String) -> float:
	if style == "melee_hammer" or style == "melee_heavy":
		return 0.18
	return 0.12


func _lunge_for_style(style: String) -> float:
	match style:
		"melee_hammer":
			return 145.0
		"melee_whip":
			return 235.0
		"melee_heavy":
			return 125.0
		_:
			return 205.0


func _place_melee_hitbox(style: String) -> void:
	var dist := 22.0
	if style == "melee_whip":
		dist = 30.0
	elif style == "melee_hammer" or style == "melee_heavy":
		dist = 18.0
	melee.position = _aim * dist
	melee.rotation = _aim.angle()


func _physics_process(delta: float) -> void:
	_update_aim()

	if current_element != _last_element:
		_refresh_element_visual()
		_last_element = current_element

	if cd_return > 0.0:
		cd_return -= delta
	if _dodge_cd > 0.0:
		_dodge_cd -= delta

	if Input.is_action_just_pressed("toggle_branch"):
		current_branch = _Stance.Branch.MELEE if current_branch == _Stance.Branch.REMOTE else _Stance.Branch.REMOTE

	if Input.is_action_just_pressed("stance_dodge") and _dodge_cd <= 0.0 and _dodge_timer <= 0.0:
		var mv := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if mv.length_squared() < 0.04:
			_dodge_dir = -_aim
		else:
			_dodge_dir = mv.normalized()
		_dodge_timer = DODGE_TIME
		_dodge_cd = DODGE_CD
		_emit_dodge_vfx()

	if Input.is_action_just_pressed("attack_move_to_location") and _attack_time <= 0.0 and _dodge_timer <= 0.0:
		_start_left_melee()

	if Input.is_action_just_pressed("attack_secondary") and _attack_time <= 0.0 and _dodge_timer <= 0.0:
		_start_right_attack()

	var move := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if _dodge_timer > 0.0:
		_dodge_timer -= delta
		velocity = _dodge_dir * DODGE_SPEED
	elif _lunge_timer > 0.0:
		_lunge_timer -= delta
		velocity = move * SPEED * 0.38 + _lunge_vec
	else:
		velocity = move * SPEED
	move_and_slide()

	if _lunge_timer > 0.0:
		_lunge_vec = _lunge_vec.move_toward(Vector2.ZERO, 1850.0 * delta)

	if _attack_time > 0.0:
		_attack_time -= delta
		var st: Dictionary = _stance()
		var mstyle: String = str(st["left_style"])
		var ps: float = float(st.get("proj_speed", 0.0))
		if _attack_time > 0.0:
			var phase := 1.0 - (_attack_time / _attack_total) if _attack_total > 0.001 else 0.0
			if _attack_mode == "left" and mstyle.begins_with("melee"):
				melee.monitoring = true
				_place_melee_hitbox(mstyle)
				for a in melee.get_overlapping_areas():
					_apply_melee_hit(a, st, false)
			elif _attack_mode == "right" and ps <= 0.0:
				var rs: String = str(st.get("right_style", mstyle))
				melee.monitoring = true
				_place_melee_hitbox(rs)
				for a in melee.get_overlapping_areas():
					_apply_melee_hit(a, st, true)
			else:
				melee.monitoring = false
			var swing_style: String = mstyle if _attack_mode == "left" else str(st.get("right_style", mstyle))
			if not _swing_emitted and _Wvis.should_emit_melee_swing(phase, _prev_attack_phase):
				_emit_melee_swing(swing_style)
				_swing_emitted = true
			_prev_attack_phase = phase
			if _visual != null:
				_visual.frame = _Wvis.attack_frame_from_phase(phase)
				var base: Color = _Wvis.sprite_tint(current_element)
				var flash := Color(1.22, 1.18, 1.1) if phase < 0.48 else Color(1.38, 1.3, 1.18)
				_visual.modulate = Color(
					base.r * flash.r,
					base.g * flash.g,
					base.b * flash.b,
					1.0
				)
		else:
			melee.monitoring = false
			_prev_attack_phase = 0.0
			if _visual != null:
				_refresh_element_visual()
				_visual.frame = 0
	else:
		melee.monitoring = false
		_prev_attack_phase = 0.0
		if _visual != null:
			_refresh_element_visual()
			_visual.frame = 0


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	if not event.pressed or event.echo:
		return
	if event.is_action_pressed("recall_swords"):
		_try_recall_swords()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rage_ult"):
		if rage >= RAGE_MAX:
			_cast_rage_ult()
			get_viewport().set_input_as_handled()


func _try_recall_swords() -> void:
	if cd_return > 0.0 or _attack_time > 0.0:
		return
	get_tree().call_group("player_flying_sword", "begin_recall", self)
	_cast_return_burst()


func _start_left_melee() -> void:
	var st: Dictionary = _stance()
	var mstyle: String = str(st["left_style"])
	var dur := _attack_duration_for(mstyle)
	_attack_time = dur
	_attack_total = dur
	_attack_mode = "left"
	_swing_emitted = false
	_prev_attack_phase = 0.0
	_lunge_timer = dur * 0.92
	_lunge_vec = _aim * _lunge_for_style(mstyle)
	_place_melee_hitbox(mstyle)


func _start_right_attack() -> void:
	var st: Dictionary = _stance()
	var ps: float = float(st.get("proj_speed", 0.0))
	if ps > 0.0:
		_fire_projectile(st)
	else:
		var mstyle: String = str(st.get("right_style", st["left_style"]))
		var dur := _attack_duration_for(mstyle)
		_attack_time = dur
		_attack_total = dur
		_attack_mode = "right"
		_swing_emitted = false
		_prev_attack_phase = 0.0
		_lunge_timer = dur * 0.75
		_lunge_vec = _aim * (_lunge_for_style(mstyle) * 0.85)
		_place_melee_hitbox(mstyle)
		if st.get("right_shield", false) == true:
			shield_hp = mini(shield_hp + 18, 50)


func _fire_projectile(st: Dictionary) -> void:
	if get_tree().get_nodes_in_group("player_flying_sword").size() >= MAX_FLYING_SWORDS:
		return
	var game := _get_game_root()
	if game == null:
		return
	var spd: float = float(st["proj_speed"])
	var dmg: int = int(st["right_damage"])
	var pierce: float = float(st.get("right_pierce_def", 0.0))
	var b: Area2D = _FlyingSwordScene.instantiate() as Area2D
	b.configure(_aim * spd, dmg, int(current_element), 1.65, pierce)
	game.add_child(b)
	b.global_position = global_position + _aim * 14.0
	var mcol: Color = _Wx.element_color(current_element)
	_Vfx.play(game, global_position + _aim * 16.0, mcol, 22.0, 0.14, _Vfx.Kind.BURST)
	rage = mini(RAGE_MAX, rage + RAGE_PER_HIT)


func _emit_melee_swing(style: String) -> void:
	var game := _get_game_root()
	if game == null:
		return
	var col: Color = _Wx.element_color(current_element)
	var r: float = _Wvis.swing_radius_for_style(style)
	var kind: int = _Wvis.melee_swing_kind(style)
	var pos: Vector2 = global_position + _aim * 10.0
	_Vfx.play(game, pos, col, r, 0.24, kind)


func _emit_dodge_vfx() -> void:
	var game := _get_game_root()
	if game == null:
		return
	var col: Color = _Wx.element_color(current_element).lerp(Color.WHITE, 0.5)
	_Vfx.play(game, global_position, col, 28.0, 0.15, _Vfx.Kind.BURST)


func _def_mul_from_left(st: Dictionary) -> float:
	return 1.0 - float(st.get("left_ignore_def", 0.0))


func _apply_melee_hit(area: Area2D, st: Dictionary, is_right: bool) -> void:
	var parent := area.get_parent()
	if parent == null:
		return
	var dmg: int = int(st["right_damage"] if is_right else st["left_damage"])
	if is_right and float(st.get("right_melee_crit_bonus", 0.0)) > 0.0:
		dmg = int(round(float(dmg) * (1.0 + float(st["right_melee_crit_bonus"]))))
	var md: Variant = parent.get("monster_data")
	if md != null and current_element == _Wx.Element.METAL and str(md.armor_kind) == "physical":
		dmg = int(round(float(dmg) * 1.06))

	if parent.has_method("take_damage_physical_scaled_def"):
		var defm: float = 1.0 if is_right else _def_mul_from_left(st)
		parent.call("take_damage_physical_scaled_def", dmg, int(current_element), defm)
	else:
		parent.call("take_damage", dmg, int(current_element), int(_Wx.DamageKind.PHYSICAL))

	rage = mini(RAGE_MAX, rage + RAGE_PER_HIT)

	var hp_before_heal := hp
	if not is_right:
		if float(st.get("left_stun_sec", 0.0)) > 0.0 and parent.has_method("apply_stun"):
			parent.call("apply_stun", float(st["left_stun_sec"]))
		if int(st.get("left_heal_on_hit", 0)) > 0:
			hp = mini(max_hp, hp + int(st["left_heal_on_hit"]))
		if int(st.get("left_lifesteal", 0)) > 0:
			hp = mini(max_hp, hp + int(st["left_lifesteal"]))
		if current_element == _Wx.Element.WOOD:
			hp = mini(max_hp, hp + 1)
	if hp > hp_before_heal:
		var game_heal := _get_game_root()
		if game_heal != null and game_heal.has_method("spawn_heal_float"):
			game_heal.call("spawn_heal_float", global_position + Vector2(0, -18), hp - hp_before_heal)

	_post_hit_status(parent, st, is_right)


func _post_hit_status(parent: Node, st: Dictionary, is_right: bool) -> void:
	if not parent.has_method("apply_skill_status"):
		return
	if st.get("left_poison", false) == true and not is_right:
		parent.call("apply_skill_status", "wood", true)
	if st.get("left_slow", false) == true and not is_right:
		parent.call("apply_skill_status", "water", false)
	if (st.get("left_burn", false) == true or st.get("left_burn_stack", false) == true) and not is_right:
		parent.call("apply_skill_status", "fire", false)
	if st.get("right_freeze", false) == true and is_right:
		parent.call("apply_skill_status", "water", true)
	if st.get("right_stun", false) == true and is_right:
		parent.call("apply_stun", 0.35)


func _cast_return_burst() -> void:
	var st: Dictionary = _stance()
	cd_return = float(st["return_cd"])
	var r: float = float(st["return_radius"])
	var base: int = int(st["return_base"])
	var vid: int = int(st["return_vfx"])
	var game := _get_game_root()
	if game == null:
		return
	var col: Color = _Wx.element_color(current_element)
	_Vfx.play(game, global_position, col, r, 0.48, vid)
	for n in get_tree().get_nodes_in_group("realtime_enemy"):
		var n2: Node2D = n as Node2D
		if global_position.distance_to(n2.global_position) <= r:
			if n.has_method("take_skill_magic_hit"):
				n.call("take_skill_magic_hit", base, int(current_element), true)
	rage = mini(RAGE_MAX, rage + 4)


func _cast_rage_ult() -> void:
	var st: Dictionary = _stance()
	var r: float = float(st["rage_radius"])
	var base: int = int(st["rage_base"])
	var vid: int = int(st["rage_vfx"])
	rage = 0
	var game := _get_game_root()
	if game == null:
		return
	var col: Color = _Wx.element_color(current_element)
	_Vfx.play(game, global_position, col, r, 0.72, vid)
	for n in get_tree().get_nodes_in_group("realtime_enemy"):
		var n2: Node2D = n as Node2D
		if global_position.distance_to(n2.global_position) <= r:
			if n.has_method("take_skill_magic_hit"):
				n.call("take_skill_magic_hit", base, int(current_element), true)
