class_name RealtimePhysics
extends RefCounted
## 即时场景物理层（与项目其它场景独立）

const LAYER_PLAYER := 1
const LAYER_WALL := 2
const LAYER_ENEMY := 4
const LAYER_HURTBOX := 16

static func mask_player_move() -> int:
	return LAYER_WALL | LAYER_ENEMY


static func mask_enemy_move() -> int:
	return LAYER_WALL | LAYER_PLAYER


static func mask_melee_hit() -> int:
	return LAYER_HURTBOX
