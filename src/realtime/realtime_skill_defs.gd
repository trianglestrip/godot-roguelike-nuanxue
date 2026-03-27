extends RefCounted
## 五行武器与 Q/E（与 docs/wuxing_skills_spec.md 对齐）
## basic_style: melee_sword | melee_whip | ranged_staff | ranged_fireball | melee_hammer | ranged_bow

const _Wx := preload("res://src/realtime/realtime_wuxing.gd")
const _Vfx := preload("res://src/realtime/realtime_skill_vfx.gd")


static func row(el: _Wx.Element) -> Dictionary:
	match el:
		_Wx.Element.METAL:
			return {
				"weapon_name": "飞羽弓",
				"basic_style": "ranged_bow",
				"basic_damage": 7,
				"proj_speed": 420.0,
				"name_q": "穿刺箭",
				"name_e": "箭幕",
				"cd_q": 5.0,
				"cd_e": 12.0,
				"range_q": 88.0,
				"range_e": 152.0,
				"base_q": 12,
				"base_e": 34,
				"vfx_q": _Vfx.Kind.SLASH_ARC,
				"vfx_e": _Vfx.Kind.SHOCK_BURST,
			}
		_Wx.Element.WOOD:
			return {
				"weapon_name": "藤鞭",
				"basic_style": "melee_whip",
				"basic_damage": 8,
				"proj_speed": 0.0,
				"name_q": "藤缚",
				"name_e": "毒雾",
				"cd_q": 6.0,
				"cd_e": 14.0,
				"range_q": 72.0,
				"range_e": 118.0,
				"base_q": 10,
				"base_e": 22,
				"vfx_q": _Vfx.Kind.VINE_SNARE,
				"vfx_e": _Vfx.Kind.POISON_CLOUD,
			}
		_Wx.Element.WATER:
			return {
				"weapon_name": "寒霜法杖",
				"basic_style": "ranged_staff",
				"basic_damage": 6,
				"proj_speed": 360.0,
				"name_q": "寒息",
				"name_e": "凝霜",
				"cd_q": 5.0,
				"cd_e": 12.0,
				"range_q": 92.0,
				"range_e": 148.0,
				"base_q": 11,
				"base_e": 28,
				"vfx_q": _Vfx.Kind.ICE_SPIKE,
				"vfx_e": _Vfx.Kind.ICE_RING,
			}
		_Wx.Element.FIRE:
			return {
				"weapon_name": "双刀与火珠",
				"basic_style": "ranged_fireball",
				"basic_damage": 9,
				"proj_speed": 300.0,
				"name_q": "流焰",
				"name_e": "焚轮",
				"cd_q": 4.2,
				"cd_e": 10.0,
				"range_q": 102.0,
				"range_e": 162.0,
				"base_q": 13,
				"base_e": 30,
				"vfx_q": _Vfx.Kind.FIRE_FAN,
				"vfx_e": _Vfx.Kind.FIRE_NOVA,
			}
		_Wx.Element.EARTH:
			return {
				"weapon_name": "盾锤",
				"basic_style": "melee_hammer",
				"basic_damage": 11,
				"proj_speed": 0.0,
				"name_q": "地刺",
				"name_e": "岩崩",
				"cd_q": 6.0,
				"cd_e": 14.0,
				"range_q": 78.0,
				"range_e": 132.0,
				"base_q": 12,
				"base_e": 26,
				"vfx_q": _Vfx.Kind.STONE_SPIKE,
				"vfx_e": _Vfx.Kind.STONE_RAIN,
			}
		_:
			return row(_Wx.Element.METAL)
