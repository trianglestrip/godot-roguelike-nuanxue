extends Node
## 无头：五行姿态表完整性 + 与 realtime_player 一致的伤害公式 + 木桩/杂兵 TTK 区间（调数值用）。

const _Wx := preload("res://src/realtime/realtime_wuxing.gd")
const _Stance := preload("res://src/realtime/realtime_stance_defs.gd")
const _MonsterData := preload("res://src/realtime/realtime_monster_data.gd")

## 与 RealtimeSkillVfx.Kind 枚举项数量一致（变更时请同步）。
const _VFX_KIND_COUNT := 12

const _REQUIRED_KEYS: Array[String] = [
	"branch_name_cn",
	"left_style",
	"left_damage",
	"return_radius",
	"return_base",
	"return_cd",
	"return_vfx",
	"rage_radius",
	"rage_base",
	"rage_vfx",
]


func _ready() -> void:
	var code := _run()
	print("HEADLESS_TEST_EXIT_CODE=", code)
	call_deferred("_quit", code)


func _quit(code: int) -> void:
	get_tree().quit(code)


func _run() -> int:
	if _assert_stance_schema() != 0:
		return 1
	if _assert_damage_sanity() != 0:
		return 1
	if _assert_ttk_bounds() != 0:
		return 1
	return 0


func _assert_stance_schema() -> int:
	var elems: Array = [
		_Wx.Element.METAL,
		_Wx.Element.WOOD,
		_Wx.Element.WATER,
		_Wx.Element.FIRE,
		_Wx.Element.EARTH,
	]
	var branches: Array = [_Stance.Branch.REMOTE, _Stance.Branch.MELEE]
	for el: Variant in elems:
		for br: Variant in branches:
			var row: Dictionary = _Stance.row(el, br)
			for k: String in _REQUIRED_KEYS:
				if not row.has(k):
					push_error("stance missing key %s for el=%s br=%s" % [k, el, br])
					return 1
			var rv: int = int(row["return_vfx"])
			var rgv: int = int(row["rage_vfx"])
			if rv < 0 or rv >= _VFX_KIND_COUNT:
				push_error("invalid return_vfx %d" % rv)
				return 1
			if rgv < 0 or rgv >= _VFX_KIND_COUNT:
				push_error("invalid rage_vfx %d" % rgv)
				return 1
			var rr: float = float(row["return_radius"])
			var rrad: float = float(row["rage_radius"])
			if rr < 90.0 or rr > 200.0:
				push_error("return_radius out of design range: %s" % rr)
				return 1
			if rrad < 280.0 or rrad > 420.0:
				push_error("rage_radius out of design range: %s" % rrad)
				return 1
	return 0


## 与 realtime_player._apply_melee_hit / _cast_return_burst / _cast_rage_ult 中伤害分支对齐（不含状态 DoT）。
func _calc_phys_melee_left(st: Dictionary, atk: _Wx.Element, md: RealtimeMonsterData) -> int:
	var dmg: int = int(st["left_damage"])
	if atk == _Wx.Element.METAL and str(md.armor_kind) == "physical":
		dmg = int(round(float(dmg) * 1.06))
	var def_mul: float = 1.0 - float(st.get("left_ignore_def", 0.0))
	var eff_def: int = int(round(float(md.physical_def) * def_mul))
	dmg = maxi(1, dmg - eff_def)
	var tgt_el: _Wx.Element = _Wx.element_from_string(md.element)
	dmg = int(round(float(dmg) * _Wx.damage_multiplier(atk, tgt_el)))
	return dmg


func _calc_phys_melee_right(st: Dictionary, atk: _Wx.Element, md: RealtimeMonsterData) -> int:
	if st.get("right_shield", false) == true:
		return 0
	var dmg: int = int(st["right_damage"])
	if float(st.get("right_melee_crit_bonus", 0.0)) > 0.0:
		dmg = int(round(float(dmg) * (1.0 + float(st["right_melee_crit_bonus"]))))
	if atk == _Wx.Element.METAL and str(md.armor_kind) == "physical":
		dmg = int(round(float(dmg) * 1.06))
	var eff_def: int = md.physical_def
	dmg = maxi(1, dmg - eff_def)
	var tgt_el: _Wx.Element = _Wx.element_from_string(md.element)
	dmg = int(round(float(dmg) * _Wx.damage_multiplier(atk, tgt_el)))
	return dmg


func _calc_phys_projectile(st: Dictionary, atk: _Wx.Element, md: RealtimeMonsterData) -> int:
	var dmg: int = int(st["right_damage"])
	var pierce: float = float(st.get("right_pierce_def", 0.0))
	var def_mul: float = 1.0 - pierce
	if atk == _Wx.Element.METAL and str(md.armor_kind) == "physical":
		dmg = int(round(float(dmg) * 1.06))
	var eff_def: int = int(round(float(md.physical_def) * def_mul))
	dmg = maxi(1, dmg - eff_def)
	var tgt_el: _Wx.Element = _Wx.element_from_string(md.element)
	dmg = int(round(float(dmg) * _Wx.damage_multiplier(atk, tgt_el)))
	return dmg


func _calc_magic_skill(base: int, atk: _Wx.Element, md: RealtimeMonsterData) -> int:
	var dmg: int = maxi(1, base - md.magic_def)
	var tgt_el: _Wx.Element = _Wx.element_from_string(md.element)
	dmg = int(round(float(dmg) * _Wx.damage_multiplier(atk, tgt_el)))
	return dmg


func _assert_damage_sanity() -> int:
	var table: Array = _MonsterData.load_table()
	var by_id: Dictionary = {}
	for m: Variant in table:
		by_id[m.id] = m
	var dummy_metal: RealtimeMonsterData = by_id.get("dummy_metal", null)
	if dummy_metal == null:
		push_error("dummy_metal missing in realtime_monsters.json")
		return 1

	for atk: int in range(5):
		var el: _Wx.Element = atk as _Wx.Element
		for br_idx in range(2):
			var br: _Stance.Branch = br_idx as _Stance.Branch
			var row: Dictionary = _Stance.row(el, br)
			var ld: int = _calc_phys_melee_left(row, el, dummy_metal)
			var rd: int = _calc_phys_melee_right(row, el, dummy_metal)
			var ret_d: int = _calc_magic_skill(int(row["return_base"]), el, dummy_metal)
			var rg_d: int = _calc_magic_skill(int(row["rage_base"]), el, dummy_metal)
			if ld < 1 or ld > 120:
				push_error("left melee out of range: %d atk=%s br=%s" % [ld, el, br_idx])
				return 1
			if rd < 0 or rd > 120:
				push_error("right melee out of range: %d atk=%s br=%s" % [rd, el, br_idx])
				return 1
			if ret_d < 1 or ret_d > 200:
				push_error("return magic out of range: %d atk=%s br=%s" % [ret_d, el, br_idx])
				return 1
			if rg_d < 1 or rg_d > 300:
				push_error("rage magic out of range: %d atk=%s br=%s" % [rg_d, el, br_idx])
				return 1
			if float(row.get("proj_speed", 0.0)) > 0.0:
				var pj: int = _calc_phys_projectile(row, el, dummy_metal)
				if pj < 1 or pj > 120:
					push_error("projectile dmg out of range: %d atk=%s br=%s" % [pj, el, br_idx])
					return 1

			print(
				(
					"WUXING_BALANCE atk=%s br=%s | L=%d R=%d proj=%d ret=%d rage=%d | %s"
					% [
						el,
						br_idx,
						ld,
						rd,
						_calc_phys_projectile(row, el, dummy_metal) if float(row.get("proj_speed", 0.0)) > 0.0 else -1,
						ret_d,
						rg_d,
						str(row["branch_name_cn"]),
					]
				)
			)
	return 0


func _ceil_div(a: int, b: int) -> int:
	if b <= 0:
		return 999999
	return (a + b - 1) / b


func _assert_ttk_bounds() -> int:
	## 木桩：仅魔法收剑返，对同系木桩需「若干次才清空」——防止数值误设为秒杀或永动机。
	var table: Array = _MonsterData.load_table()
	var dummies: Dictionary = {}
	for m: Variant in table:
		if str(m.id).begins_with("dummy_"):
			dummies[m.element] = m

	var pest: RealtimeMonsterData = null
	for m: Variant in table:
		if m.id == "pest_earth":
			pest = m
			break
	if pest == null:
		push_error("pest_earth missing")
		return 1

	for atk: int in range(5):
		var el: _Wx.Element = atk as _Wx.Element
		var row: Dictionary = _Stance.row(el, _Stance.Branch.REMOTE)
		var tgt: RealtimeMonsterData = dummies.get(_Wx.element_key(el), null)
		if tgt == null:
			continue
		var ret_d: int = _calc_magic_skill(int(row["return_base"]), el, tgt)
		var hits: int = _ceil_div(tgt.hp, ret_d)
		if hits < 3 or hits > 80:
			push_error("dummy TTK (return only) suspicious: hits=%d el=%s hp=%d dmg=%d" % [hits, el, tgt.hp, ret_d])
			return 1

	## 杂兵 pest_earth：左键近战最小/最大 TTK 应在合理区间（随姿态表变化时失败则人工调边界）。
	var min_hits := 99
	var max_hits := 0
	for atk2: int in range(5):
		var el2: _Wx.Element = atk2 as _Wx.Element
		for br2_idx in range(2):
			var r2: Dictionary = _Stance.row(el2, br2_idx as _Stance.Branch)
			var d: int = _calc_phys_melee_left(r2, el2, pest)
			var h: int = _ceil_div(pest.hp, d)
			min_hits = mini(min_hits, h)
			max_hits = maxi(max_hits, h)
	if min_hits < 2 or max_hits > 25:
		push_error("pest_earth melee TTK range [%d,%d] outside [2,25]" % [min_hits, max_hits])
		return 1

	print("WUXING_TTK pest_earth melee hits range: [%d, %d]" % [min_hits, max_hits])
	return 0
