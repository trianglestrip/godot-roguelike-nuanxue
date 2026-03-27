extends SceneTree
## 控制台入口：headless 运行阶段 0 / A / B 测试。
## 可选：`-- --test-phase=0|a|b`（默认 all）。


const _Phase0 := preload("res://tests/automation/phase_0_tests.gd")
const _PhaseA := preload("res://tests/automation/phase_a_tests.gd")
const _PhaseB := preload("res://tests/automation/phase_b_tests.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var filter := _phase_filter()
	var errs: Array[String] = []
	if filter in ["all", "0"]:
		var p0 = _Phase0.new()
		errs.append_array(p0.run())
	if filter in ["all", "a"]:
		var pa = _PhaseA.new()
		errs.append_array(pa.run())
	if filter in ["all", "b"]:
		var pb = _PhaseB.new()
		errs.append_array(pb.run(self))
	if errs.size() > 0:
		for e in errs:
			push_error(e)
		quit(1)
	else:
		quit(0)


func _phase_filter() -> String:
	if OS.has_method("get_cmdline_user_args"):
		for a in OS.get_cmdline_user_args():
			if str(a).begins_with("--test-phase="):
				return str(a).get_slice("=", 1).strip_edges().to_lower()
	for a in OS.get_cmdline_args():
		if str(a).begins_with("--test-phase="):
			return str(a).get_slice("=", 1).strip_edges().to_lower()
	return "all"
