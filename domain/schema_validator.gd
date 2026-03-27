extends RefCounted
class_name SchemaValidator
## 仅校验 data/ 中 JSON 形状，不写战斗表现。


static func validate_skill_data(d: Dictionary) -> String:
	if not d.has("id"):
		return "skill: missing id"
	if not d.has("name"):
		return "skill: missing name"
	if not d.has("cooldown_sec"):
		return "skill: missing cooldown_sec"
	if typeof(d["cooldown_sec"]) != TYPE_FLOAT and typeof(d["cooldown_sec"]) != TYPE_INT:
		return "skill: cooldown_sec must be number"
	return ""


static func validate_relic_data(d: Dictionary) -> String:
	if not d.has("id"):
		return "relic: missing id"
	if not d.has("name"):
		return "relic: missing name"
	if not d.has("slot"):
		return "relic: missing slot"
	var slot := str(d["slot"])
	var ok: bool = slot in ["core", "power", "agility", "skill"]
	if not ok:
		return "relic: invalid slot"
	return ""
