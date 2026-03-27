extends RefCounted
class_name DataLoader
## 只负责从 res://data 读取与 JSON 解析，不实现游戏规则。


static func load_json_dictionary(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("DataLoader: file not found: %s" % path)
		return {}
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		push_error("DataLoader: empty file: %s" % path)
		return {}
	var any: Variant = JSON.parse_string(text)
	if typeof(any) != TYPE_DICTIONARY:
		push_error("DataLoader: root must be object: %s" % path)
		return {}
	return any as Dictionary
