extends CanvasLayer
## 试玩 HUD：操作说明 + 玩家坐标。


@onready var label: Label = $Label


func _ready() -> void:
	if label:
		label.text = "WASD 移动  |  Space 冲刺（无敌帧）  |  J 攻击"


func _process(_delta: float) -> void:
	var p := get_tree().get_first_node_in_group("player") as Node2D
	if label == null:
		return
	if p:
		label.text = "WASD 移动  |  Space 冲刺  |  J 攻击\npos: (%d, %d)" % [
			int(p.global_position.x),
			int(p.global_position.y),
		]
