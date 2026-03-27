extends RefCounted
class_name DamageContext
## 领域层：伤害上下文与纯函数规则，供单测与 Simulation 调用。


static func compute_final_damage(base_amount: float, crit_multiplier: float, is_crit: bool) -> float:
	var m := crit_multiplier if is_crit else 1.0
	return base_amount * m


static func apply_armor_flat(amount: float, armor_flat: float) -> float:
	return maxf(0.0, amount - armor_flat)
