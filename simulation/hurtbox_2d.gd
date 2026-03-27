extends Area2D
class_name Hurtbox2D
## 受击盒：只在 `hurtbox` 物理层上可被 Hitbox 的 mask 扫到。

const _CombatLayers := preload("res://simulation/combat_layers.gd")


func _ready() -> void:
	collision_layer = _CombatLayers.hurtbox_layer_bits()
	collision_mask = 0
	monitoring = false
	monitorable = true


## 无敌帧期间关闭受击（不挡物理移动，仅不参与 overlap 判定）。
func set_hurt_enabled(enabled: bool) -> void:
	monitorable = enabled
	collision_layer = _CombatLayers.hurtbox_layer_bits() if enabled else 0
