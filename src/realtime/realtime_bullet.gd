extends Area2D
## 简易投射物：命中 Hurtbox（layer 16）

const _Wx := preload("res://src/realtime/realtime_wuxing.gd")

var _vel: Vector2 = Vector2.ZERO
var _dmg: int = 6
var _elem: int = 0
var _life: float = 1.6
## 无视防御比例（0~1），与姿态 `right_pierce_def` 一致；命中时有效物防 = 物防 × (1 - 该值)。
var _ignore_physical_def: float = 0.0
var _configured: bool = false
var _trail: Array[Vector2] = []
const _TRAIL_MAX := 14


func configure(
	velocity: Vector2,
	damage: int,
	atk_element: int,
	lifetime: float = 1.6,
	ignore_physical_def: float = 0.0
) -> void:
	_vel = velocity
	_dmg = damage
	_elem = atk_element
	_life = lifetime
	_ignore_physical_def = clampf(ignore_physical_def, 0.0, 1.0)
	_configured = true


func _ready() -> void:
	if not _configured:
		queue_free()
		return
	collision_layer = 0
	collision_mask = 16
	monitoring = true
	area_entered.connect(_on_area_entered)
	z_index = 45


func _physics_process(delta: float) -> void:
	global_position += _vel * delta
	_trail.append(global_position)
	if _trail.size() > _TRAIL_MAX:
		_trail.remove_at(0)
	queue_redraw()
	_life -= delta
	if _life <= 0.0:
		queue_free()


func _draw() -> void:
	var c: Color = _Wx.element_color(_elem as _Wx.Element)
	if _trail.size() >= 2:
		for i in range(1, _trail.size()):
			var a: Vector2 = to_local(_trail[i - 1])
			var b: Vector2 = to_local(_trail[i])
			var t: float = float(i) / float(_trail.size())
			draw_line(a, b, Color(c.r, c.g, c.b, 0.12 + t * 0.38), 1.2 + t * 1.6)
	draw_circle(Vector2.ZERO, 3.2, Color(c.r, c.g, c.b, 0.85))
	draw_circle(Vector2.ZERO, 1.6, Color(1.0, 1.0, 1.0, 0.5))


func _on_area_entered(area: Area2D) -> void:
	if area.name != &"Hurtbox":
		return
	var p: Node = area.get_parent()
	if p == null:
		queue_free()
		return
	var def_mul: float = 1.0 - _ignore_physical_def
	if p.has_method("take_damage_physical_scaled_def"):
		p.call("take_damage_physical_scaled_def", _dmg, _elem, def_mul)
	elif p.has_method("take_damage"):
		p.call("take_damage", _dmg, _elem, int(_Wx.DamageKind.PHYSICAL))
	queue_free()
