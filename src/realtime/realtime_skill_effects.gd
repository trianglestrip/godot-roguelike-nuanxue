extends RefCounted
## 五行技能命中后的状态逻辑（调用 RealtimeEnemy 上的方法）；与 docs/wuxing_skills_spec.md 对齐。

const _Wx := preload("res://src/realtime/realtime_wuxing.gd")


static func apply_after_magic_hit(enemy: CharacterBody2D, atk_el: int, is_e: bool) -> void:
	if enemy == null or not enemy.has_method("apply_skill_status"):
		return
	var el: _Wx.Element = atk_el as _Wx.Element
	enemy.call("apply_skill_status", _Wx.element_key(el), is_e)
