extends Node2D

var worlds
var dynamic_collision
var dynamic_base

var tile_size = 16

func _ready():
	worlds = get_node("worlds")
	dynamic_collision = get_node("worlds/dynamic_collision")
	print(dynamic_collision.get_owner())
	dynamic_base = preload("res://scenes/dynamic_collider_base.tscn")
	generate_dynamic_collision(worlds.get_node("world_1").get_pos(), worlds.get_node("world_1").walkable)
	pass

func world_collision(world):
	# world has just ended a movement
	
	# get all connected worlds into one single array
	var union = world.connected_worlds
	var union_check
	var searching = true
	while searching:
		union_check = union
		for joined_world in union:
			for adjacent in joined_world.connected_worlds:
				if !union.has(adjacent):
					union.append(adjacent)
		if union_check == union:
			searching = false
	
	# iterate over this array and create a complete 2d array representing walkable tiles over the entire system
	var new_data = [world.get_pos(), world.walkable]
	for w in union:
		# do not consider colliding world as we just added it to the new_data
		if w == world:
			continue
		
		new_data = combined_world_data(new_data[0], new_data[1], w.get_pos(), w.walkable)
	
	# now generate dynamic collision!
	generate_dynamic_collision(new_data[0], new_data[1])

func combined_world_data(origin1, walkable1, origin2, walkable2):
	# origin1, walkable1 consist of world data for the first world
	# origin2, walkable2 consist of world data for the second world
	var maxy_1 = 0
	var maxy_2 = 0
	for arr in walkable1:
		maxy_1 = max(maxy_1, arr.size())
	for arr in walkable2:
		maxy_2 = max(maxy_2, arr.size())
	
	# various variables
	var e1 = origin1 + tile_size * Vector2(walkable1.size(), maxy_1)
	var e2 = origin2 + tile_size * Vector2(walkable2.size(), maxy_2)
	
	var o3pos = Vector2(min(origin1.x, origin2.x), min(origin1.y, origin2.y))
	var o3 = vec2toindex(o3pos)
	var e3 = vec2toindex(Vector2(max(e1.x, e2.x), max(e1.y, e2.y)))
	
	# initialize new_walkables as empty
	var new_walkables = []
	for x in range(0, e3.x - o3.x):
		new_walkables.append([])
		for y in range(0, e3.y - o3.y):
			 new_walkables[x].append(0)
	
	# insert w1 walkables data
	for x in range(postoindex(origin1.x), postoindex(e1.x)):
		for y in range(postoindex(origin1.y), postoindex(e1.y)):
			new_walkables[x - o3.x][y - o3.y] = walkable1[x - postoindex(origin1.x)][y - postoindex(origin1.y)]
	
	# insert w2 walkables data
	for x in range(postoindex(origin2.x), postoindex(e2.x)):
		for y in range(postoindex(origin2.y), postoindex(e2.y)):
			new_walkables[x - o3.x][y - o3.y] = walkable2[x - postoindex(origin2.x)][y - postoindex(origin2.y)]
	
	# new_walkables is now filled with the relevant walkable data
	# now return it for reuse or collision generation
	return [o3pos, new_walkables]

func generate_dynamic_collision(origin, walkables):
	print("new origin: " + str(origin))
	# remove all existing dynamic collision and reset dynamic colliders' position
	for child in dynamic_collision.get_children():
		child.queue_free()
	dynamic_collision.set_pos(Vector2(0, 0))
	
	# generate within-map collision
	for x in range(0, walkables.size()):
		for y in range(0, walkables[0].size()):
			if walkables[x][y] == 0:
				create_collision(origin + tile_size * Vector2(x + 0.5, y + 0.5))
	# generate edge collision
	for x in range(0, walkables.size()):
		create_collision(origin + tile_size * Vector2(x + 0.5, -0.5))
		create_collision(origin + tile_size * Vector2(x + 0.5, walkables[0].size() + 0.5))
	for y in range(0, walkables[0].size()):
		create_collision(origin + tile_size * Vector2(-0.5, y + 0.5))
		create_collision(origin + tile_size * Vector2(walkables.size() + 0.5, y + 0.5))

func create_collision(pos):
	var coll = dynamic_base.instance()
	dynamic_collision.add_child(coll)
	coll.set_pos(pos)
	pass

func toint(f):
	return int(round(f))

func postoindex(f):
	return toint(f / tile_size)

func vec2toindex(v):
	return Vector2(postoindex(v.x), postoindex(v.y))