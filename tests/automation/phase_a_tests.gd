extends RefCounted
## 阶段 A：Schema + DataLoader + EventBus 信号（无场景依赖）。

const _DataLoader := preload("res://domain/data_loader.gd")
const _SchemaValidator := preload("res://domain/schema_validator.gd")
const _AutoloadAccess := preload("res://core/autoload_access.gd")


class _HitProbe extends RefCounted:
	var fired: bool = false

	func _on_hit(_d: Dictionary) -> void:
		fired = true


func run() -> Array[String]:
	var errs: Array[String] = []
	var skill_path := "res://data/skills/example_skill.json"
	var relic_path := "res://data/relics/example_relic.json"
	var skill: Dictionary = _DataLoader.load_json_dictionary(skill_path)
	var e1: String = _SchemaValidator.validate_skill_data(skill)
	if e1 != "":
		errs.append("phase_a skill schema: %s" % e1)
	var relic: Dictionary = _DataLoader.load_json_dictionary(relic_path)
	var e2: String = _SchemaValidator.validate_relic_data(relic)
	if e2 != "":
		errs.append("phase_a relic schema: %s" % e2)

	var probe := _HitProbe.new()
	var eb: Node = _AutoloadAccess.event_bus()
	eb.connect("combat_hit", Callable(probe, "_on_hit"))
	eb.emit_signal("combat_hit", {"test": true})
	eb.disconnect("combat_hit", Callable(probe, "_on_hit"))
	if not probe.fired:
		errs.append("phase_a: EventBus.combat_hit did not fire")
	return errs
