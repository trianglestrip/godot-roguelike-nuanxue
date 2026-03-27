extends Area2D
class_name Hitbox2D
## 攻击盒：监听与 Hurtbox 的重叠，发射 EventBus.combat_hit 并触发 HitStop（可配置）。

const _CombatLayers := preload("res://simulation/combat_layers.gd")
const _HitStopService := preload("res://simulation/hit_stop_service.gd")
const _HurtboxScript := preload("res://simulation/hurtbox_2d.gd")

@export var damage: float = 12.0
@export var hit_stop_scale: float = 0.12
@export var hit_stop_seconds: float = 0.06

var _attacker: Node2D
var _hit_instance_ids: Dictionary = {}


func _ready() -> void:
	collision_layer = _CombatLayers.hitbox_layer_bits()
	collision_mask = _CombatLayers.hitbox_collision_mask()
	monitoring = true
	monitorable = false
	area_entered.connect(_on_area_entered)


func configure(attacker: Node2D, dmg: float) -> void:
	_attacker = attacker
	damage = dmg


func _is_hurtbox(area: Area2D) -> bool:
	return area.get_script() == _HurtboxScript


func _on_area_entered(area: Area2D) -> void:
	if not _is_hurtbox(area):
		return
	var target: Node = area.get_parent()
	if target == null:
		return
	var iid: int = target.get_instance_id()
	if _hit_instance_ids.has(iid):
		return
	_hit_instance_ids[iid] = true
	var payload := {
		"attacker": _attacker,
		"target": target,
		"damage": damage,
		"position": global_position,
	}
	EventBus.emit_combat_hit(payload)
	_HitStopService.push_hit_stop(hit_stop_scale)
	var tree := get_tree()
	if tree == null:
		_HitStopService.pop_hit_stop()
		return
	var t := tree.create_timer(hit_stop_seconds, false, false, true)
	t.timeout.connect(func() -> void:
		_HitStopService.pop_hit_stop()
	)
