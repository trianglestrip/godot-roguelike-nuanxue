extends Node2D
## 伤害飘字：置于 FxLayer（高于单位、低于屏幕 HUD）。

const _FONT: Font = preload("res://assets/fonts/pixel_operator/PixelOperatorSC.ttf")
const LIFE := 0.72
const RISE := 38.0

var _age := 0.0
var _label: Label


func setup(amount: int, color: Color, outline: Color = Color(0, 0, 0, 0.85)) -> void:
	z_index = 2
	_label = Label.new()
	_label.text = "-%d" % amount
	_label.add_theme_font_override("font", _FONT)
	_label.add_theme_font_size_override("font_size", 11)
	_label.add_theme_color_override("font_color", color)
	_label.add_theme_color_override("font_outline_color", outline)
	_label.add_theme_constant_override("outline_size", 3)
	_label.position = Vector2(-20, -8)
	add_child(_label)


func setup_heal(amount: int) -> void:
	z_index = 2
	_label = Label.new()
	_label.text = "+%d" % amount
	_label.add_theme_font_override("font", _FONT)
	_label.add_theme_font_size_override("font_size", 11)
	_label.add_theme_color_override("font_color", Color(0.45, 0.95, 0.55))
	_label.add_theme_color_override("font_outline_color", Color(0, 0.12, 0.06, 0.9))
	_label.add_theme_constant_override("outline_size", 3)
	_label.position = Vector2(-18, -8)
	add_child(_label)


func _process(delta: float) -> void:
	_age += delta
	position.y -= RISE * delta
	modulate.a = 1.0 - smoothstep(0.35, LIFE, _age)
	if _age >= LIFE:
		queue_free()
