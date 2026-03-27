class_name RealtimeSkillVfx
extends RefCounted

enum Kind {
	BURST,
	SLASH_ARC,
	SHOCK_BURST,
	VINE_SNARE,
	POISON_CLOUD,
	ICE_SPIKE,
	ICE_RING,
	FIRE_FAN,
	FIRE_NOVA,
	STONE_SPIKE,
	STONE_RAIN,
}


static func play(game: Node2D, world_pos: Vector2, color: Color, radius: float, duration: float, kind: int = Kind.BURST) -> void:
	var n := _BurstFx.new()
	n.setup(color, radius, duration, kind)
	n.global_position = world_pos
	game.add_child(n)


class _BurstFx extends Node2D:
	var _color: Color
	var _r: float
	var _t: float
	var _kind: int = Kind.BURST
	var _age: float = 0.0


	func setup(color: Color, radius: float, duration: float, kind: int) -> void:
		_color = color
		_r = radius
		_t = maxf(duration, 0.05)
		_kind = kind


	func _ready() -> void:
		z_index = 50


	func _process(delta: float) -> void:
		_age += delta
		queue_redraw()
		if _age >= _t:
			queue_free()


	func _draw() -> void:
		var u: float = clampf(_age / _t, 0.0, 1.0)
		var k: float = smoothstep(0.0, 1.0, u)
		var a: float = lerpf(0.62, 0.0, k)
		var c := Color(_color.r, _color.g, _color.b, a)

		match _kind:
			Kind.BURST:
				_draw_burst(c, k)
			Kind.SLASH_ARC:
				_draw_slash_arcs(c, k)
			Kind.SHOCK_BURST:
				_draw_shock_burst(c, k)
			Kind.VINE_SNARE:
				_draw_vine_snare(c, k)
			Kind.POISON_CLOUD:
				_draw_poison_cloud(c, k)
			Kind.ICE_SPIKE:
				_draw_ice_spike(c, k)
			Kind.ICE_RING:
				_draw_ice_ring(c, k)
			Kind.FIRE_FAN:
				_draw_fire_fan(c, k)
			Kind.FIRE_NOVA:
				_draw_fire_nova(c, k)
			Kind.STONE_SPIKE:
				_draw_stone_spike(c, k)
			Kind.STONE_RAIN:
				_draw_stone_rain(c, k)
			_:
				_draw_burst(c, k)


	func _draw_burst(c: Color, k: float) -> void:
		var a := c.a * lerpf(0.5, 0.0, k)
		draw_circle(Vector2.ZERO, _r * lerpf(0.35, 1.0, k), Color(c.r, c.g, c.b, a * 0.45))
		draw_arc(Vector2.ZERO, _r * 0.85, 0.0, TAU, 48, Color(c.r, c.g, c.b, a), 2.0, true)


	func _draw_slash_arcs(c: Color, k: float) -> void:
		var a := c.a * 0.9
		for i in 3:
			var ang := float(i) * TAU / 3.0 + k * 0.8
			draw_arc(Vector2.ZERO, _r * lerpf(0.4, 1.0, k), ang, ang + PI * 0.45, 16, Color(c.r, c.g, c.b, a * (1.0 - k * 0.4)), 3.0, true)


	func _draw_shock_burst(c: Color, k: float) -> void:
		var n := 12
		for i in n:
			var ang := float(i) / float(n) * TAU + k * 0.2
			var len := _r * lerpf(0.3, 1.0, k)
			var p1 := Vector2(cos(ang), sin(ang)) * len * 0.4
			var p2 := Vector2(cos(ang), sin(ang)) * len
			draw_line(p1, p2, Color(c.r, c.g, c.b, c.a * (1.0 - k)), 2.5)
		draw_circle(Vector2.ZERO, _r * 0.25 * (1.0 - k * 0.5), Color(c.r, c.g, c.b, c.a * 0.35))


	func _draw_vine_snare(c: Color, k: float) -> void:
		var ellipse := Vector2(_r * 1.1, _r * 0.55)
		for i in 5:
			var t := float(i) / 5.0
			var rot := k * TAU * 0.25 + t * PI
			var pts: PackedVector2Array = PackedVector2Array()
			for j in 13:
				var p := float(j) / 12.0 * TAU
				var wobble := sin(p * 3.0 + rot) * 6.0
				pts.append(Vector2(cos(p + rot), sin(p + rot) * 0.5) * ellipse + Vector2(wobble, 0.0))
			draw_polyline(pts, Color(c.r, c.g, c.b, c.a * (0.7 - k * 0.3)), 2.0)


	func _draw_poison_cloud(c: Color, k: float) -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = 12345
		for i in 18:
			var ang := rng.randf() * TAU
			var rad := rng.randf_range(_r * 0.15, _r * 0.92)
			var p := Vector2(cos(ang), sin(ang)) * rad
			var s := rng.randf_range(3.0, 9.0)
			draw_circle(p, s * (1.0 - k * 0.5), Color(c.r * 0.7, c.g, c.b * 0.6, c.a * 0.35 * (1.0 - k)))
		draw_arc(Vector2.ZERO, _r * 0.9, 0.0, TAU, 40, Color(c.r, c.g, c.b, c.a * 0.4), 2.0, true)


	func _fill_poly(pts: PackedVector2Array, col: Color) -> void:
		draw_colored_polygon(pts, col)


	func _draw_ice_spike(c: Color, k: float) -> void:
		for i in 6:
			var ang := float(i) / 6.0 * TAU
			var tip := Vector2(cos(ang), sin(ang)) * _r * lerpf(0.5, 1.0, k)
			var side := Vector2(-sin(ang), cos(ang)) * 8.0
			var base := tip * 0.2
			var pts: PackedVector2Array = PackedVector2Array([base + side, tip, base - side])
			_fill_poly(pts, Color(c.r, c.g, c.b, c.a * 0.75))


	func _draw_ice_ring(c: Color, k: float) -> void:
		draw_arc(Vector2.ZERO, _r * lerpf(0.5, 1.0, k), 0.0, TAU, 56, Color(0.85, 0.95, 1.0, c.a * 0.85), 3.0, true)
		draw_arc(Vector2.ZERO, _r * 0.72, 0.0, TAU, 48, Color(c.r, c.g, c.b, c.a * 0.5), 2.0, true)


	func _draw_fire_fan(c: Color, k: float) -> void:
		var start := -PI * 0.35
		var end := PI * 0.35
		draw_arc(Vector2.ZERO, _r * lerpf(0.4, 1.0, k), start, end, 24, Color(1.0, 0.5, 0.2, c.a * 0.9), 4.0, true)
		draw_arc(Vector2.ZERO, _r * 0.6 * lerpf(0.4, 1.0, k), start * 0.9, end * 0.9, 20, Color(1.0, 0.85, 0.3, c.a * 0.6), 2.0, true)


	func _draw_fire_nova(c: Color, k: float) -> void:
		for ring in 3:
			var rr := _r * (0.35 + float(ring) * 0.22) * lerpf(0.4, 1.0, k)
			draw_arc(Vector2.ZERO, rr, 0.0, TAU, 48, Color(1.0, 0.45 + ring * 0.1, 0.1, c.a * (0.5 - ring * 0.12)), 2.5 + ring, true)
		draw_circle(Vector2.ZERO, _r * 0.2, Color(1.0, 0.9, 0.4, c.a * 0.4 * (1.0 - k)))


	func _draw_stone_spike(c: Color, k: float) -> void:
		for i in 8:
			var ang := float(i) / 8.0 * TAU
			var h := _r * lerpf(0.3, 0.95, k)
			var w := 6.0
			var tip := Vector2(cos(ang), sin(ang)) * h
			var orth := Vector2(-sin(ang), cos(ang)) * w
			var pts: PackedVector2Array = PackedVector2Array([-orth * 0.3, tip, orth * 0.3])
			_fill_poly(pts, Color(c.r * 0.9, c.g * 0.85, c.b * 0.7, c.a * 0.8))


	func _draw_stone_rain(c: Color, k: float) -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = 54321
		for i in 14:
			var x := rng.randf_range(-_r, _r)
			var y := rng.randf_range(-_r, _r) + k * _r * 0.4
			var r := Vector2(x, y)
			draw_rect(Rect2(r, Vector2(4.0, 10.0 + rng.randf() * 6.0)), Color(c.r * 0.8, c.g * 0.75, c.b * 0.6, c.a * (0.5 - k * 0.25)))
