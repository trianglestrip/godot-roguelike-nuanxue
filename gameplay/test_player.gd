extends CharacterBody2D
## 试玩用玩家：移动、冲刺（无敌帧关闭 Hurtbox）、朝向、攻击生成 Hitbox。

const _DashController := preload("res://simulation/dash_controller.gd")

@export var move_speed: float = 220.0
@export var dash_speed: float = 520.0
@export var dash_duration: float = 0.14
@export var invuln_duration: float = 0.12
@export var attack_cooldown: float = 0.26
@export var attack_damage: float = 14.0
@export var hitbox_lifetime: float = 0.14
@export var arena_rect: Rect2 = Rect2(16, 16, 544, 292)

@onready var hurtbox: Node = $Hurtbox

var _dash = _DashController.new()
var _attack_cd: float = 0.0
var _facing: Vector2 = Vector2.RIGHT

const SWING_HITBOX := preload("res://scenes/playtest/swing_hitbox.tscn")


func _ready() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	_dash.process_delta(delta)
	_attack_cd = maxf(0.0, _attack_cd - delta)
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir.length_squared() > 0.0001:
		_facing = dir.normalized()
	hurtbox.call("set_hurt_enabled", not _dash.is_invulnerable())
	if Input.is_action_just_pressed("dash") and not _dash.is_dashing():
		_dash.start_dash(dash_duration, invuln_duration)
		EventBus.emit_player_dashed({"attacker": self, "position": global_position})
	var spd := dash_speed if _dash.is_dashing() else move_speed
	velocity = dir * spd
	move_and_slide()
	global_position.x = clampf(global_position.x, arena_rect.position.x, arena_rect.position.x + arena_rect.size.x)
	global_position.y = clampf(global_position.y, arena_rect.position.y, arena_rect.position.y + arena_rect.size.y)
	if Input.is_action_just_pressed("attack") and _attack_cd <= 0.0:
		_attack_cd = attack_cooldown
		_spawn_swing()


func _spawn_swing() -> void:
	var swing: Node = SWING_HITBOX.instantiate()
	var parent := get_parent()
	if parent == null:
		return
	parent.add_child(swing)
	if swing.has_method("configure"):
		swing.call("configure", self, attack_damage)
	var offset := _facing * 30.0
	swing.global_position = global_position + offset
	get_tree().create_timer(hitbox_lifetime).timeout.connect(func() -> void:
		swing.queue_free()
	)
