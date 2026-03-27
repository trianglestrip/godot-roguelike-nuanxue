extends Node2D
## 试玩木桩：监听 combat_hit，扣血并显示；血量归零发 enemy_killed。

@export var max_hp: float = 100.0

var hp: float = 0.0

@onready var hurtbox: Node = $Hurtbox
@onready var hp_label: Label = $HpLabel


func _ready() -> void:
	hp = max_hp
	_update_label()
	EventBus.combat_hit.connect(_on_combat_hit)


func _on_combat_hit(data: Dictionary) -> void:
	var t: Node = data.get("target", null) as Node
	if t != self:
		return
	var dmg: float = float(data.get("damage", 0.0))
	hp = maxf(0.0, hp - dmg)
	_update_label()
	modulate = Color(1.0, 0.75, 0.75) if hp < max_hp * 0.4 else Color.WHITE
	if hp <= 0.0:
		EventBus.emit_enemy_killed({"target": self, "position": global_position})
		visible = false
		hurtbox.call("set_hurt_enabled", false)
		set_process(false)


func _update_label() -> void:
	if hp_label:
		hp_label.text = "木桩 HP: %.0f / %.0f" % [hp, max_hp]
