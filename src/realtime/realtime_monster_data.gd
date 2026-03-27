class_name RealtimeMonsterData
extends RefCounted

const _SCRIPT: GDScript = preload("res://src/realtime/realtime_monster_data.gd")

var id: String
var display_name: String
var character_tile: StringName
var hp: int
var physical_def: int
var magic_def: int
var armor_kind: String
var element: String
var attack_kind: String
var speed_scale: float = 1.0


static func load_table(path: String = "res://assets/data/realtime_monsters.json") -> Array:
	var out: Array = []
	var txt := FileAccess.get_file_as_string(path)
	if txt.is_empty():
		push_error("Missing or empty: %s" % path)
		return out
	var parsed: Variant = JSON.parse_string(txt)
	if parsed == null or typeof(parsed) != TYPE_ARRAY:
		push_error("Invalid JSON array: %s" % path)
		return out
	for item: Variant in parsed:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var d: Dictionary = item
		var m: RefCounted = _SCRIPT.new() as RefCounted
		m.id = str(d.get("id", ""))
		m.display_name = str(d.get("display_name", m.id))
		m.character_tile = StringName(str(d.get("character_tile", "pest-17")))
		m.hp = int(d.get("hp", 20))
		m.physical_def = int(d.get("physical_def", 0))
		m.magic_def = int(d.get("magic_def", 0))
		m.armor_kind = str(d.get("armor_kind", "physical"))
		m.element = str(d.get("element", "earth"))
		m.attack_kind = str(d.get("attack_kind", "physical"))
		m.speed_scale = float(d.get("speed_scale", 1.0))
		out.append(m)
	return out
