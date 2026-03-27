extends RefCounted
## 五行表现：立绘 Atlas、近战挥砍特效 Kind、半径；与 `character_tiles.json` 中 player-* 条目对应。

const _Wx := preload("res://src/realtime/realtime_wuxing.gd")
const _Vfx := preload("res://src/realtime/realtime_skill_vfx.gd")


static func player_sprite_name(el: _Wx.Element) -> StringName:
	match el:
		_Wx.Element.METAL:
			return &"player-4"
		_Wx.Element.WOOD:
			return &"player-25"
		_Wx.Element.WATER:
			return &"player-31"
		_Wx.Element.FIRE:
			return &"player-4"
		_Wx.Element.EARTH:
			return &"player-31"
	return &"player-4"


## 与五行主色轻度混合，区分金/火等同图不同系。
static func sprite_tint(el: _Wx.Element) -> Color:
	var c: Color = _Wx.element_color(el)
	return Color(
		lerpf(1.0, c.r, 0.38),
		lerpf(1.0, c.g, 0.38),
		lerpf(1.0, c.b, 0.38),
		1.0
	)


static func melee_swing_kind(style: String) -> int:
	match style:
		"melee_whip":
			return _Vfx.Kind.VINE_SNARE
		"melee_hammer":
			return _Vfx.Kind.STONE_SPIKE
		"melee_heavy":
			return _Vfx.Kind.SHOCK_BURST
		_:
			return _Vfx.Kind.SLASH_ARC


static func swing_radius_for_style(style: String) -> float:
	match style:
		"melee_whip":
			return 40.0
		"melee_hammer":
			return 34.0
		"melee_heavy":
			return 36.0
		_:
			return 38.0


## 归一化攻击进度 0=起手 1=收招，驱动 2 帧精灵：前段 0、判定峰 1。
static func attack_frame_from_phase(phase: float) -> int:
	var p: float = clampf(phase, 0.0, 1.0)
	return 1 if p >= 0.38 else 0


static func should_emit_melee_swing(phase: float, prev_phase: float) -> bool:
	return prev_phase < 0.42 and phase >= 0.42
