extends Area2D
## 暖雪式飞剑：飞行（像素帧）→ 命中或超时插地 → 收剑飞向玩家并造成路径伤害。

const _Wx := preload("res://src/realtime/realtime_wuxing.gd")

const _PATHS: Array[String] = [
	"res://assets/realtime/projectiles/flying_sword_metal.png",
	"res://assets/realtime/projectiles/flying_sword_wood.png",
	"res://assets/realtime/projectiles/flying_sword_water.png",
	"res://assets/realtime/projectiles/flying_sword_fire.png",
	"res://assets/realtime/projectiles/flying_sword_earth.png",
]

enum State {
	FLYING,
	STUCK,
	RECALLING,
}

const RECALL_SPEED := 720.0
const PICKUP_DIST := 14.0

var _vel: Vector2 = Vector2.ZERO
var _dmg: int = 6
var _recall_dmg: int = 2
var _elem: int = 0
var _life: float = 1.65
var _ignore_physical_def: float = 0.0
var _state: State = State.FLYING
var _configured: bool = false
var _recall_target: Node2D
var _recall_hit_ids: Dictionary = {}
var _anim_t: float = 0.0
var _sprite: Sprite2D


func configure(
	velocity: Vector2,
	damage: int,
	atk_element: int,
	lifetime: float = 1.65,
	ignore_physical_def: float = 0.0,
	recall_damage: int = -1
) -> void:
	_vel = velocity
	_dmg = damage
	_elem = atk_element
	_life = lifetime
	_ignore_physical_def = clampf(ignore_physical_def, 0.0, 1.0)
	if recall_damage < 0:
		_recall_dmg = maxi(1, int(round(float(damage) * 0.34)))
	else:
		_recall_dmg = recall_damage
	_configured = true


func _ready() -> void:
	if not _configured:
		queue_free()
		return
	add_to_group("player_flying_sword")
	collision_layer = 0
	collision_mask = 16
	monitoring = true
	area_entered.connect(_on_area_entered)
	z_index = 46

	_sprite = get_node_or_null("Sprite2D") as Sprite2D
	if _sprite == null:
		_sprite = Sprite2D.new()
		_sprite.name = "Sprite2D"
		add_child(_sprite)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.centered = true
	var idx: int = clampi(_elem, 0, 4)
	var tex: Texture2D = _load_strip_texture(_PATHS[idx])
	if tex != null:
		_sprite.texture = tex
		_sprite.hframes = 4
		_sprite.vframes = 1
	var tint: Color = _Wx.element_color(_elem as _Wx.Element)
	_sprite.modulate = Color(tint.r * 1.08, tint.g * 1.08, tint.b * 1.08, 1.0)


func _load_strip_texture(path: String) -> Texture2D:
	var img := Image.new()
	var err: Error = img.load(path)
	if err != OK:
		push_warning("flying_sword texture load failed: ", path)
		return null
	return ImageTexture.create_from_image(img)


func begin_recall(target: Node2D) -> void:
	if _state == State.RECALLING:
		return
	if _state != State.FLYING and _state != State.STUCK:
		return
	_recall_target = target
	_state = State.RECALLING
	_recall_hit_ids.clear()
	monitoring = true
	_vel = Vector2.ZERO


func _physics_process(delta: float) -> void:
	match _state:
		State.FLYING:
			_life -= delta
			global_position += _vel * delta
			_anim_t += delta * 14.0
			if _sprite != null and _sprite.texture != null:
				_sprite.frame = int(_anim_t) % maxi(1, _sprite.hframes * _sprite.vframes)
				if _vel.length_squared() > 1.0:
					_sprite.rotation = _vel.angle()
			if _life <= 0.0:
				_state = State.STUCK
				monitoring = false
				if _sprite != null:
					_sprite.frame = 3
		State.STUCK:
			if _sprite != null:
				_sprite.frame = 3
		State.RECALLING:
			if _recall_target == null or not is_instance_valid(_recall_target):
				queue_free()
				return
			var to_p: Vector2 = _recall_target.global_position - global_position
			var step: float = minf(RECALL_SPEED * delta, to_p.length())
			if to_p.length_squared() < PICKUP_DIST * PICKUP_DIST:
				queue_free()
				return
			global_position += to_p.normalized() * step
			_anim_t += delta * 22.0
			if _sprite != null and _sprite.texture != null:
				var nf: int = maxi(1, _sprite.hframes * _sprite.vframes)
				_sprite.frame = int(_anim_t) % nf
				_sprite.rotation = to_p.angle()
			_apply_recall_hits()


func _apply_recall_hits() -> void:
	for area in get_overlapping_areas():
		if area.name != &"Hurtbox":
			continue
		var parent: Node = area.get_parent()
		if parent == null:
			continue
		var id: int = parent.get_instance_id()
		if _recall_hit_ids.has(id):
			continue
		_recall_hit_ids[id] = true
		var def_mul: float = 1.0 - _ignore_physical_def
		if parent.has_method("take_damage_physical_scaled_def"):
			parent.call("take_damage_physical_scaled_def", _recall_dmg, _elem, def_mul)
		elif parent.has_method("take_damage"):
			parent.call("take_damage", _recall_dmg, _elem, int(_Wx.DamageKind.PHYSICAL))


func _on_area_entered(area: Area2D) -> void:
	if _state != State.FLYING:
		return
	if area.name != &"Hurtbox":
		return
	var p: Node = area.get_parent()
	if p == null:
		return
	var def_mul: float = 1.0 - _ignore_physical_def
	if p.has_method("take_damage_physical_scaled_def"):
		p.call("take_damage_physical_scaled_def", _dmg, _elem, def_mul)
	elif p.has_method("take_damage"):
		p.call("take_damage", _dmg, _elem, int(_Wx.DamageKind.PHYSICAL))
	_state = State.STUCK
	_vel = Vector2.ZERO
	monitoring = false
	if _sprite != null:
		_sprite.frame = 3
