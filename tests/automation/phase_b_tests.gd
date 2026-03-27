extends RefCounted
## 阶段 B：伤害、冲刺无敌、碰撞层、HitStop、CameraAdapter（无渲染）。

const _DamageContext := preload("res://domain/damage_context.gd")
const _DashController := preload("res://simulation/dash_controller.gd")
const _CombatLayers := preload("res://simulation/combat_layers.gd")
const _HitStopService := preload("res://simulation/hit_stop_service.gd")
const _CameraAdapter := preload("res://presentation/camera_adapter.gd")
const _AutoloadAccess := preload("res://core/autoload_access.gd")


func run(tree: SceneTree) -> Array[String]:
	var errs: Array[String] = []
	_test_damage(errs)
	_test_dash(errs)
	_test_layers(errs)
	_test_hit_stop(errs)
	_test_camera_adapter(tree, errs)
	return errs


func _test_damage(errs: Array[String]) -> void:
	var v: float = _DamageContext.compute_final_damage(10.0, 2.0, true)
	if not is_equal_approx(v, 20.0):
		errs.append("phase_b: crit damage expected 20 got %s" % v)
	var v2: float = _DamageContext.apply_armor_flat(10.0, 3.0)
	if not is_equal_approx(v2, 7.0):
		errs.append("phase_b: armor flat expected 7 got %s" % v2)


func _test_dash(errs: Array[String]) -> void:
	var d = _DashController.new()
	d.start_dash(0.2, 0.15)
	if not d.is_invulnerable():
		errs.append("phase_b: should be invuln after start_dash")
	d.process_delta(0.1)
	if not d.is_invulnerable():
		errs.append("phase_b: invuln should last 0.15s")
	d.process_delta(0.2)
	if d.is_invulnerable():
		errs.append("phase_b: invuln should end")


func _test_layers(errs: Array[String]) -> void:
	var m: int = _CombatLayers.hitbox_collision_mask()
	var expected: int = 1 << (_CombatLayers.LAYER_HURTBOX - 1)
	if m != expected:
		errs.append("phase_b: hitbox mask mismatch %s vs %s" % [m, expected])


func _test_hit_stop(errs: Array[String]) -> void:
	_HitStopService.reset_for_tests()
	_HitStopService.push_hit_stop(0.05)
	if not is_equal_approx(Engine.time_scale, 0.05):
		errs.append("phase_b: hit stop scale")
	_HitStopService.pop_hit_stop()
	if not is_equal_approx(Engine.time_scale, 1.0):
		errs.append("phase_b: hit stop restore")
	_HitStopService.reset_for_tests()


func _test_camera_adapter(tree: SceneTree, errs: Array[String]) -> void:
	var ca: Node = _CameraAdapter.new()
	tree.get_root().add_child(ca)
	var eb: Node = _AutoloadAccess.event_bus()
	eb.emit_signal("combat_hit", {"probe": 1})
	if ca.shake_count != 1:
		errs.append("phase_b: CameraAdapter expected shake_count 1 got %s" % ca.shake_count)
	ca.queue_free()
