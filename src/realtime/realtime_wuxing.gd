class_name RealtimeWuxing
extends RefCounted

enum Element { METAL, WOOD, WATER, FIRE, EARTH }

enum DamageKind { PHYSICAL, MAGICAL }

const ELEMENT_KEYS: Array[String] = ["metal", "wood", "water", "fire", "earth"]


static func element_from_index(i: int) -> Element:
	match clampi(i, 0, 4):
		0:
			return Element.METAL
		1:
			return Element.WOOD
		2:
			return Element.WATER
		3:
			return Element.FIRE
		_:
			return Element.EARTH


static func element_from_string(s: String) -> Element:
	var idx := ELEMENT_KEYS.find(s.to_lower())
	if idx < 0:
		return Element.EARTH
	return idx as Element


static func element_key(e: Element) -> String:
	return ELEMENT_KEYS[int(e)]


static func element_color(e: Element) -> Color:
	match e:
		Element.METAL:
			return Color(0.82, 0.84, 0.88)
		Element.WOOD:
			return Color(0.45, 0.78, 0.42)
		Element.WATER:
			return Color(0.42, 0.62, 0.95)
		Element.FIRE:
			return Color(0.95, 0.45, 0.35)
		Element.EARTH:
			return Color(0.72, 0.55, 0.38)
	return Color.WHITE


static func element_name_cn(e: Element) -> String:
	match e:
		Element.METAL:
			return "金"
		Element.WOOD:
			return "木"
		Element.WATER:
			return "水"
		Element.FIRE:
			return "火"
		Element.EARTH:
			return "土"
	return "?"


static func damage_multiplier(atk: Element, target: Element) -> float:
	var a := int(atk)
	var t := int(target)
	if (a + 1) % 5 == t:
		return 1.25
	if (t + 1) % 5 == a:
		return 0.8
	return 1.0
