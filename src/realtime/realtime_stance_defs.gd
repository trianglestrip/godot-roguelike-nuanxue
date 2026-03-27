extends RefCounted
## 暖雪式：五行 × 双分支（远程/近战）战斗数据；与 docs/idea.md 对齐。

const _Wx := preload("res://src/realtime/realtime_wuxing.gd")
const _Vfx := preload("res://src/realtime/realtime_skill_vfx.gd")

enum Branch {
	REMOTE,
	MELEE,
}


static func row(el: _Wx.Element, br: Branch) -> Dictionary:
	match el:
		_Wx.Element.METAL:
			if br == Branch.REMOTE:
				return _metal_remote()
			return _metal_melee()
		_Wx.Element.WOOD:
			if br == Branch.REMOTE:
				return _wood_remote()
			return _wood_melee()
		_Wx.Element.WATER:
			if br == Branch.REMOTE:
				return _water_remote()
			return _water_melee()
		_Wx.Element.FIRE:
			if br == Branch.REMOTE:
				return _fire_remote()
			return _fire_melee()
		_Wx.Element.EARTH:
			if br == Branch.REMOTE:
				return _earth_remote()
			return _earth_melee()
		_:
			return _metal_remote()


static func _metal_remote() -> Dictionary:
	return {
		"branch_name_cn": "锐金流",
		"left_style": "melee_blade",
		"left_damage": 9,
		"left_ignore_def": 0.10,
		"right_damage": 8,
		"right_pierce_def": 0.50,
		"proj_speed": 430.0,
		"return_radius": 118.0,
		"return_base": 26,
		"return_cd": 2.0,
		"return_vfx": _Vfx.Kind.SHOCK_BURST,
		"rage_radius": 360.0,
		"rage_base": 50,
		"rage_vfx": _Vfx.Kind.SHOCK_BURST,
	}


static func _metal_melee() -> Dictionary:
	return {
		"branch_name_cn": "玄金流",
		"left_style": "melee_heavy",
		"left_damage": 13,
		"left_ignore_def": 0.0,
		"left_stun_sec": 0.22,
		"right_damage": 10,
		"right_melee_crit_bonus": 0.20,
		"proj_speed": 0.0,
		"return_radius": 120.0,
		"return_base": 28,
		"return_cd": 2.1,
		"return_vfx": _Vfx.Kind.STONE_SPIKE,
		"rage_radius": 360.0,
		"rage_base": 54,
		"rage_vfx": _Vfx.Kind.SHOCK_BURST,
	}


static func _wood_remote() -> Dictionary:
	return {
		"branch_name_cn": "青木流",
		"left_style": "melee_whip",
		"left_damage": 8,
		"left_poison": true,
		"right_damage": 7,
		"right_summon_snare": true,
		"proj_speed": 340.0,
		"return_radius": 116.0,
		"return_base": 24,
		"return_cd": 2.0,
		"return_vfx": _Vfx.Kind.POISON_CLOUD,
		"rage_radius": 360.0,
		"rage_base": 42,
		"rage_vfx": _Vfx.Kind.POISON_CLOUD,
	}


static func _wood_melee() -> Dictionary:
	return {
		"branch_name_cn": "神木流",
		"left_style": "melee_whip",
		"left_damage": 9,
		"left_heal_on_hit": 2,
		"right_damage": 8,
		"right_ally_burst": true,
		"proj_speed": 0.0,
		"return_radius": 118.0,
		"return_base": 22,
		"return_cd": 2.2,
		"return_vfx": _Vfx.Kind.VINE_SNARE,
		"rage_radius": 360.0,
		"rage_base": 40,
		"rage_vfx": _Vfx.Kind.VINE_SNARE,
	}


static func _water_remote() -> Dictionary:
	return {
		"branch_name_cn": "寒水流",
		"left_style": "melee_blade",
		"left_damage": 8,
		"left_slow": true,
		"right_damage": 7,
		"right_freeze": true,
		"proj_speed": 360.0,
		"return_radius": 114.0,
		"return_base": 26,
		"return_cd": 2.0,
		"return_vfx": _Vfx.Kind.ICE_RING,
		"rage_radius": 360.0,
		"rage_base": 44,
		"rage_vfx": _Vfx.Kind.ICE_RING,
	}


static func _water_melee() -> Dictionary:
	return {
		"branch_name_cn": "沧水流",
		"left_style": "melee_blade",
		"left_damage": 9,
		"left_slow": true,
		"left_lifesteal": 1,
		"right_damage": 0,
		"right_shield": true,
		"proj_speed": 0.0,
		"return_radius": 116.0,
		"return_base": 24,
		"return_cd": 2.1,
		"return_vfx": _Vfx.Kind.ICE_SPIKE,
		"rage_radius": 360.0,
		"rage_base": 42,
		"rage_vfx": _Vfx.Kind.ICE_SPIKE,
	}


static func _fire_remote() -> Dictionary:
	return {
		"branch_name_cn": "烈炎流",
		"left_style": "melee_blade",
		"left_damage": 9,
		"left_burn": true,
		"right_damage": 10,
		"right_aoe_burn": true,
		"proj_speed": 310.0,
		"return_radius": 118.0,
		"return_base": 28,
		"return_cd": 1.9,
		"return_vfx": _Vfx.Kind.FIRE_NOVA,
		"rage_radius": 360.0,
		"rage_base": 48,
		"rage_vfx": _Vfx.Kind.FIRE_NOVA,
	}


static func _fire_melee() -> Dictionary:
	return {
		"branch_name_cn": "焚天流",
		"left_style": "melee_blade",
		"left_damage": 10,
		"left_burn_stack": true,
		"right_damage": 11,
		"right_aoe_melee": true,
		"proj_speed": 0.0,
		"return_radius": 122.0,
		"return_base": 38,
		"return_cd": 2.4,
		"return_vfx": _Vfx.Kind.FIRE_NOVA,
		"rage_radius": 360.0,
		"rage_base": 56,
		"rage_vfx": _Vfx.Kind.FIRE_NOVA,
	}


static func _earth_remote() -> Dictionary:
	return {
		"branch_name_cn": "厚土流",
		"left_style": "melee_hammer",
		"left_damage": 10,
		"left_thorns": true,
		"right_damage": 9,
		"right_stun": true,
		"proj_speed": 280.0,
		"return_radius": 112.0,
		"return_base": 26,
		"return_cd": 2.1,
		"return_vfx": _Vfx.Kind.STONE_RAIN,
		"rage_radius": 360.0,
		"rage_base": 46,
		"rage_vfx": _Vfx.Kind.STONE_RAIN,
	}


static func _earth_melee() -> Dictionary:
	return {
		"branch_name_cn": "磐石流",
		"left_style": "melee_hammer",
		"left_damage": 12,
		"left_dr": 0.08,
		"right_damage": 0,
		"right_stone_armor": true,
		"proj_speed": 0.0,
		"return_radius": 120.0,
		"return_base": 28,
		"return_cd": 2.2,
		"return_vfx": _Vfx.Kind.STONE_SPIKE,
		"rage_radius": 360.0,
		"rage_base": 50,
		"rage_vfx": _Vfx.Kind.STONE_RAIN,
	}
