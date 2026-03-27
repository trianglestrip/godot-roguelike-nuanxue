extends Node2D
## 地板 + 墙：用 Sprite2D + WorldTiles 图集（与 MapRenderer 同源，避免 TileMap set_cell 与 TileSet 坐标不一致）
## 物理边界：StaticBody2D，layer=2

const MAP_W_TILES := 40
const MAP_H_TILES := 25
const TILE_PX := 16


func _ready() -> void:
	_build_visuals()
	_build_bounds()


func _build_visuals() -> void:
	var floor_tex: Texture2D = WorldTiles.get_texture(&"floor-7-nsew")
	var wall_tex: Texture2D = WorldTiles.get_texture(&"wall-5-nsew")
	var layer := Node2D.new()
	layer.name = "TileSprites"
	layer.z_index = -20
	add_child(layer)

	for x in range(MAP_W_TILES):
		for y in range(MAP_H_TILES):
			var spr := Sprite2D.new()
			spr.centered = false
			spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			spr.position = Vector2(x * TILE_PX, y * TILE_PX)
			if x == 0 or y == 0 or x == MAP_W_TILES - 1 or y == MAP_H_TILES - 1:
				spr.texture = wall_tex
			else:
				spr.texture = floor_tex
			layer.add_child(spr)

	# 供自动化查找「地图有内容」
	layer.add_to_group("realtime_floor_sprites")


func _build_bounds() -> void:
	var w_px := float(MAP_W_TILES * TILE_PX)
	var h_px := float(MAP_H_TILES * TILE_PX)
	var t := float(TILE_PX)
	_add_wall_segment(Vector2(w_px * 0.5, -t * 0.5), Vector2(w_px, t))
	_add_wall_segment(Vector2(w_px * 0.5, h_px + t * 0.5), Vector2(w_px, t))
	_add_wall_segment(Vector2(-t * 0.5, h_px * 0.5), Vector2(t, h_px))
	_add_wall_segment(Vector2(w_px + t * 0.5, h_px * 0.5), Vector2(t, h_px))


func _add_wall_segment(center: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = center
	body.collision_layer = 2
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	body.add_child(shape)
	add_child(body)
