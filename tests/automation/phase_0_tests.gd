extends RefCounted
## 阶段 0：烟测（资源存在、主场景可解析）。


func run() -> Array[String]:
	var errs: Array[String] = []
	if not ResourceLoader.exists("res://scenes/bootstrap/main.tscn"):
		errs.append("phase0: missing res://scenes/bootstrap/main.tscn")
	if not ResourceLoader.exists("res://core/event_bus.gd"):
		errs.append("phase0: missing EventBus script")
	if not FileAccess.file_exists("res://data/_example/placeholder.json"):
		errs.append("phase0: missing placeholder.json")
	return errs
