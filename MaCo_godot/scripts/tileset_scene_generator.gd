tool
extends Node

export(bool) var reset = false setget onReset
export(String) var image_name = ""
export var tileSize = 16
export(Array) var regions # Rect2 - tile x start, tile y start, num tiles horiz, num tiles vert
export(Array) var stragglers # Rect2 - tile xpos, tile ypos (both in # tiles), tile width, tile height

#config
var spritesheet

func _ready():
    pass

func onReset(isTriggered):
	spritesheet = load("res://images/" + image_name)
	if (isTriggered):
		reset = false
		# remove all existing tiles before loading
		for child in get_children():
			child.free()
		
		# load all tiles
		loadRegions()
		loadStragglers()

func loadRegions():
	var region_id = "_"
	for region in regions:
		for y in range(region.pos.y, region.end.y):
			for x in range(region.pos.x, region.end.x):
				var tile = Sprite.new()
				add_child(tile)
				tile.set_owner(self)
				tile.set_name(region_id + str(x+y*(region.end.x - region.pos.x)))
				tile.set_texture(spritesheet)
				tile.set_region(true)
				tile.set_region_rect(Rect2(x*tileSize, y*tileSize, tileSize, tileSize))
				tile.set_pos(Vector2(x*tileSize+tileSize/2, y*tileSize+tileSize/2))
		region_id = "r" + region_id
func loadStragglers():
	for i in range(stragglers.size()):
		var start = stragglers[i].pos
		var size = tileSize * stragglers[i].size
		print(start)
		print(size)
		
		var tile = Sprite.new()
		add_child(tile)
		tile.set_owner(self)
		tile.set_name("straggler_" + str(i))
		tile.set_texture(spritesheet)
		tile.set_region(true)
		tile.set_region_rect(Rect2(start.x * tileSize, start.y * tileSize, size.x, size.y))
		tile.set_pos(Vector2(size.x / 2, size.y / 2) + Vector2(tileSize * start.x, tileSize * start.y))