class_name RealtimeEnemy
extends CharacterBody2D

const _Wx := preload("res://src/realtime/realtime_wuxing.gd")
const _SkillEffects := preload("res://src/realtime/realtime_skill_effects.gd")
const _HpBarScript: GDScript = preload("res://src/realtime/realtime_unit_hp_bar.gd")
const _CJK_FONT: Font = preload("res://assets/fonts/pixel_operator/PixelOperatorSC.ttf")

const BASE_SPEED := 42.0
const AGGRO_RADIUS := 240.0
const VULN_MAGIC_MULT := 1.12

var monster_data: Variant

@export var character_tile: StringName = &"pest-17"
@export var is_training_dummy: bool = false

var hp: int = 24
var max_hp: int = 24
var physical_def: int = 0
var magic_def: int = 0
var element_key: String = "earth"

var _hit_iframe := 0.0
var _target: Node2D
var _visual: Sprite2D
var _name_label: Label
var _hp_bar: Node2D
var _move_speed: float = BASE_SPEED

var _vuln_magic_timer := 0.0
var _root_timer := 0.0
var _slow_timer := 0.0
var _slow_mult := 1.0

var _poison_timer := 0.0
var _poison_tick := 0.0
var _poison_dmg := 2

var _burn_timer := 0.0
var _burn_tick := 0.0
var _burn_dmg := 1
var _burn_interval := 0.35


func _ready() -> void:
	collision_layer = 4
	collision_mask = 2 | 1
	add_to_group("realtime_enemy")

	if monster_data != null:
		hp = monster_data.hp
		max_hp = hp
		physical_def = monster_data.physical_def
		magic_def = monster_data.magic_def
		element_key = monster_data.element
		character_tile = monster_data.character_tile
		var sc := float(monster_data.speed_scale)
		_move_speed = BASE_SPEED * sc

	_visual = Sprite2D.new()
	_visual.name = "VisualSprite"
	_visual.texture = CharacterTiles.get_texture(character_tile)
	_visual.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_visual.centered = true
	_visual.hframes = CharacterTiles.FRAMES_PER_TILE
	_visual.position = Vector2(0, -4)
	_visual.z_index = 1
	add_child(_visual)

	_hp_bar = Node2D.new()
	_hp_bar.set_script(_HpBarScript)
	_hp_bar.name = "HpBar"
	_hp_bar.position = Vector2(0, -26)
	add_child(_hp_bar)
	_hp_bar.call("set_values", hp, max_hp, Color(0.9, 0.38, 0.34, 0.95))

	_name_label = Label.new()
	_name_label.name = "OverheadLabel"
	_name_label.text = monster_data.display_name if monster_data else str(character_tile)
	_name_label.add_theme_font_size_override("font_size", 8)
	_name_label.add_theme_font_override("font", _CJK_FONT)
	_name_label.position = Vector2(-32, -40)
	_name_label.z_index = 5
	add_child(_name_label)


func set_target(p: Node2D) -> void:
	if is_training_dummy:
		return
	_target = p


func _physics_process(delta: float) -> void:
	if _hit_iframe > 0.0:
		_hit_iframe -= delta
	if _vuln_magic_timer > 0.0:
		_vuln_magic_timer -= delta
	if _root_timer > 0.0:
		_root_timer -= delta
	if _slow_timer > 0.0:
		_slow_timer -= delta
		if _slow_timer <= 0.0:
			_slow_mult = 1.0

	_tick_poison_burn(delta)
	_update_chase_movement(delta)


func _tick_poison_burn(delta: float) -> void:
	if _poison_timer > 0.0:
		_poison_timer -= delta
		_poison_tick -= delta
		while _poison_tick <= 0.0 and _poison_timer > 0.0:
			take_dot_damage(_poison_dmg)
			_poison_tick += 0.5

	if _burn_timer > 0.0:
		_burn_timer -= delta
		_burn_tick -= delta
		while _burn_tick <= 0.0 and _burn_timer > 0.0:
			take_dot_damage(_burn_dmg)
			_burn_tick += _burn_interval


func _update_chase_movement(_delta: float) -> void:
	if is_training_dummy:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	if _target == null or not is_instance_valid(_target):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_p := _target.global_position - global_position
	var dist := to_p.length()

	if _visual != null and absf(to_p.x) > 2.0:
		_visual.flip_h = to_p.x < 0.0

	if dist > AGGRO_RADIUS:
		velocity = Vector2.ZERO
	elif _root_timer > 0.0:
		velocity = Vector2.ZERO
	elif dist > 6.0:
		var sm := _slow_mult if _slow_timer > 0.0 else 1.0
		velocity = to_p.normalized() * _move_speed * sm
	else:
		velocity = Vector2.ZERO
	move_and_slide()


func take_dot_damage(amount: int) -> void:
	hp -= amount
	_refresh_hp_bar()
	_flash_damage_popup(amount, false, true)
	if _visual != null:
		_visual.modulate = Color(0.75, 1.0, 0.65)
		get_tree().create_timer(0.06).timeout.connect(
			func() -> void:
				if is_instance_valid(_visual):
					_visual.modulate = Color.WHITE
		)
	if hp <= 0:
		queue_free()


func take_damage_physical_scaled_def(base: int, atk_element: int, physical_def_multiplier: float) -> void:
	if _hit_iframe > 0.0:
		return
	_hit_iframe = 0.14
	var atk_el: _Wx.Element = atk_element as _Wx.Element
	var eff_def: int = int(round(float(physical_def) * physical_def_multiplier))
	var dmg: int = maxi(1, base - eff_def)
	var tgt_el: _Wx.Element = _Wx.element_from_string(element_key)
	dmg = int(round(float(dmg) * _Wx.damage_multiplier(atk_el, tgt_el)))
	hp -= dmg
	_refresh_hp_bar()
	_flash_damage_popup(dmg, false, false)
	if hp <= 0:
		queue_free()


func apply_stun(duration: float) -> void:
	_root_timer = maxf(_root_timer, duration)


func take_damage(base: int, atk_element: int, kind: int) -> void:
	if _hit_iframe > 0.0:
		return
	_hit_iframe = 0.14
	var atk_el: _Wx.Element = atk_element as _Wx.Element
	var dmg_kind: _Wx.DamageKind = kind as _Wx.DamageKind
	var def := physical_def if dmg_kind == _Wx.DamageKind.PHYSICAL else magic_def
	var dmg: int = maxi(1, base - def)
	var tgt_el: _Wx.Element = _Wx.element_from_string(element_key)
	dmg = int(round(float(dmg) * _Wx.damage_multiplier(atk_el, tgt_el)))
	hp -= dmg
	_refresh_hp_bar()
	_flash_damage_popup(dmg, false, false)
	if hp <= 0:
		queue_free()


func take_skill_magic_hit(base: int, atk_element: int, is_e: bool) -> void:
	if _hit_iframe > 0.0:
		return
	_hit_iframe = 0.14
	var def := magic_def
	var dmg: int = maxi(1, base - def)
	if _vuln_magic_timer > 0.0:
		dmg = int(round(float(dmg) * VULN_MAGIC_MULT))
	var atk_el: _Wx.Element = atk_element as _Wx.Element
	var tgt_el: _Wx.Element = _Wx.element_from_string(element_key)
	dmg = int(round(float(dmg) * _Wx.damage_multiplier(atk_el, tgt_el)))
	hp -= dmg
	_refresh_hp_bar()
	_flash_damage_popup(dmg, true, false)
	_SkillEffects.apply_after_magic_hit(self, atk_element, is_e)
	if hp <= 0:
		queue_free()


func apply_skill_status(el_key: String, is_e: bool) -> void:
	match el_key:
		"metal":
			_vuln_magic_timer = maxf(_vuln_magic_timer, 3.0)
		"wood":
			if not is_e:
				_root_timer = maxf(_root_timer, 0.35)
			else:
				_poison_timer = maxf(_poison_timer, 4.0)
				_poison_dmg = 2
				_poison_tick = 0.5
		"water":
			if not is_e:
				_slow_timer = maxf(_slow_timer, 2.5)
				_slow_mult = 0.52
			else:
				_root_timer = maxf(_root_timer, 0.55)
				_slow_timer = maxf(_slow_timer, 2.0)
				_slow_mult = 0.52
		"fire":
			if not is_e:
				_burn_timer = maxf(_burn_timer, 1.8)
				_burn_dmg = 1
				_burn_interval = 0.35
				_burn_tick = 0.35
			else:
				_burn_timer = maxf(_burn_timer, 2.4)
				_burn_dmg = 2
				_burn_interval = 0.3
				_burn_tick = 0.3
		"earth":
			if not is_e:
				_root_timer = maxf(_root_timer, 0.18)
			else:
				_root_timer = maxf(_root_timer, 0.28)
		_:
			pass


func _refresh_hp_bar() -> void:
	if _hp_bar != null:
		_hp_bar.call("set_values", hp, max_hp, Color(0.9, 0.38, 0.34, 0.95))


func _flash_damage_popup(dmg: int, is_magic: bool, is_dot: bool) -> void:
	var root: Node = get_tree().get_first_node_in_group("realtime_game_root")
	if root != null and root.has_method("spawn_damage_float"):
		var col: Color
		if is_dot:
			col = Color(0.5, 0.92, 0.42)
		elif is_magic:
			col = Color(0.62, 0.88, 1.0)
		else:
			col = Color(1.0, 0.52, 0.38)
		root.call("spawn_damage_float", global_position + Vector2(randf_range(-3.0, 3.0), -20.0), dmg, col)

	if _visual != null:
		_visual.modulate = Color(1.6, 0.7, 0.7)
		get_tree().create_timer(0.08).timeout.connect(
			func() -> void:
				if is_instance_valid(_visual):
					_visual.modulate = Color.WHITE
		)
