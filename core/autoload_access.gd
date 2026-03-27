extends RefCounted
class_name AutoloadAccess
## 在任意可拿到 SceneTree 的上下文（含 headless -s）中解析 Autoload 节点，避免依赖全局标识符解析顺序。


static func event_bus() -> Node:
	var st: SceneTree = Engine.get_main_loop() as SceneTree
	assert(st != null, "AutoloadAccess: SceneTree missing")
	return st.get_root().get_node("EventBus") as Node
