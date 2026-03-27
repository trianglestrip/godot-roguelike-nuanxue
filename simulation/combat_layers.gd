extends RefCounted
class_name CombatLayers
## 与 project.godot [layer_names] 2d_physics 对齐（层号从 1 起）。


const LAYER_WORLD := 1
const LAYER_HURTBOX := 2
const LAYER_HITBOX := 3


static func layer_bit(layer_index_one_based: int) -> int:
	return 1 << (layer_index_one_based - 1)


## Hitbox 应检测 Hurtbox 所在层。
static func hitbox_collision_mask() -> int:
	return layer_bit(LAYER_HURTBOX)


## Hurtbox 通常与 World / Hitbox 交互策略由项目定；单测只校验位运算一致性。
static func hurtbox_collision_layer() -> int:
	return layer_bit(LAYER_HURTBOX)


## 供 Area2D 直接赋值：`collision_layer = ...`
static func hitbox_layer_bits() -> int:
	return layer_bit(LAYER_HITBOX)


static func hurtbox_layer_bits() -> int:
	return layer_bit(LAYER_HURTBOX)


static func world_layer_bits() -> int:
	return layer_bit(LAYER_WORLD)
