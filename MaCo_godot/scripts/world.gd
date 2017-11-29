extends KinematicBody2D

export var walkable = [[]] # walkable[x][y] is column x, row y
export var onload_connected_worlds = [] # a list of all worlds connected to this one at start of runtime

var dynamic_collision
var dynamic_offset

var world_movespeed = 10
var moving = null
var previous_move = null
var target_pos # type vec2

var tile_size = 16
var default_least_dist = 1000000
var raycast_extent = 500000 # how far to raycast outwards

var connected_worlds = [] # a list of all connected worlds

func _ready():
	set_fixed_process(true)
	set_collision_margin(0) # allow sliding
	dynamic_collision = get_parent().get_node("dynamic_collision")
	dynamic_offset = get_pos()
	
	if !onload_connected_worlds.empty():
		for nodepath in onload_connected_worlds:
			connected_worlds.append(get_node(nodepath))

func _fixed_process(delta):
	if moving == "up":
		move(Vector2(0, -world_movespeed * delta))
		if abs(get_pos().y - target_pos.y) <= 0.1:
			end_movement()
	if moving == "down":
		move(Vector2(0, world_movespeed * delta))
		if abs(get_pos().y - target_pos.y) <= 0.1:
			end_movement()
	if moving == "left":
		move(Vector2(-world_movespeed * delta, 0))
		if abs(get_pos().x - target_pos.x) <= 0.1:
			end_movement()
	if moving == "right":
		move(Vector2(world_movespeed * delta, 0))
		if abs(get_pos().x - target_pos.x) <= 0.1:
			end_movement()
	if moving != null:
		# keep the dynamic collision updated to the right position
		dynamic_collision.set_pos(get_pos() - dynamic_offset)

func end_movement():
	moving = null
	print(get_name() + " landed!")
	set_pos(roundvec2(target_pos))
	
	target_pos = null
	dynamic_offset = get_pos() # necessary to keep dynamic collision position relative to current global position
	
	# connect worlds
	if is_colliding():
		if !connected_worlds.has(get_collider()):
			connected_worlds.append(get_collider())
		if !get_collider().connected_worlds.has(self):
			get_collider().connected_worlds.append(self)
	
	get_tree().call_group(2, "root", "world_collision", self)

func begin_transition(dir):
	# this is a function which takes in a direction and calculates the
	# minimum distance the island can move before hitting another island.
	# a movement in this direction is then started.
	
	# TODO: ADD IN SFX FOR NOT BEING ABLE TO MOVE IN A DIRECTION, AS WELL AS SFX FOR STARTING TRANSITION
	
	if dir == previous_move:
		return
	
	var least_dist = default_least_dist # initialize to pointlessly large value
	var delta
	if dir == "up":
		var upmost_pos
		for x in range(0, walkable.size()):
			for y in range(0, walkable[0].size()):
				# iterate downwards to find the first walkable
				if walkable[x][y] == 1:
					# first walkable found: get position of tile
					upmost_pos = get_global_pos() + tile_size * Vector2(x + 0.5, y)
					
					# raycast from tile
					var space_state = get_world_2d().get_direct_space_state()
					var result = space_state.intersect_ray(upmost_pos, upmost_pos + Vector2(0, -raycast_extent), [self], 4)
					
					# if nothing was found, exit this inner loop
					if result.empty(): break
					
					# calculate delta and assign it as least distance if it is lower
					delta = upmost_pos.y - result.position.y
					if delta < least_dist:
						least_dist = delta
		# now that we have calculated least distance, start world transition (if a world was found)
		if least_dist != default_least_dist && least_dist > 0.1:
			target_pos = get_pos() + Vector2(0, -least_dist)
			start_movement(dir)
	if dir == "down":
		var downmost_pos
		for x in range(0, walkable.size()):
			for y in range(0, walkable[0].size()):
				# iterate upwards to find the first walkable
				y = walkable[0].size() - 1 - y
				if walkable[x][y] == 1:
					# first walkable found: get position of tile
					downmost_pos = get_global_pos() + tile_size * Vector2(x + 0.5, y + 1)
					# raycast from tile
					var space_state = get_world_2d().get_direct_space_state()
					var result = space_state.intersect_ray(downmost_pos, downmost_pos + Vector2(0, raycast_extent), [self], 4)
					# if nothing was found, exit this inner loop
					if result.empty(): break
					# calculate delta and assign it as least distance if it is lower
					delta = result.position.y - downmost_pos.y
					if delta < least_dist:
						least_dist = delta
		if least_dist != default_least_dist && least_dist > 0.1:
			target_pos = get_pos() + Vector2(0, least_dist)
			start_movement(dir)
	if dir == "left":
		var leftmost_pos
		for y in range(0, walkable[0].size()):
			for x in range(0, walkable.size()):
				# iterate forwards to find the first walkable
				if walkable[x][y] == 1:
					# first walkable found: get position of tile
					leftmost_pos = get_global_pos() + tile_size * Vector2(x, y + 0.5)
					# raycast from tile
					var space_state = get_world_2d().get_direct_space_state()
					var result = space_state.intersect_ray(leftmost_pos, leftmost_pos + Vector2(-raycast_extent, 0), [self], 4)
					# if nothing was found, exit this inner loop
					if result.empty(): break
					# calculate delta and assign it as least distance if it is lower
					delta = leftmost_pos.x - result.position.x
					if delta < least_dist:
						least_dist = delta
		if least_dist != default_least_dist && least_dist > 0.1:
			target_pos = get_pos() + Vector2(-least_dist, 0)
			start_movement(dir)
	if dir == "right":
		var rightmost_pos
		for y in range(0, walkable[0].size()):
			for x in range(0, walkable.size()):
				# iterate backwards to find the first walkable
				x = walkable.size() - 1 - x
				if walkable[x][y] == 1:
					# first walkable found: get position of tile
					rightmost_pos = get_global_pos() + tile_size * Vector2(x + 1, y + 0.5)
					# raycast from tile
					var space_state = get_world_2d().get_direct_space_state()
					var result = space_state.intersect_ray(rightmost_pos, rightmost_pos + Vector2(raycast_extent, 0), [self], 4)
					# if nothing was found, exit this inner loop
					if result.empty(): break
					# calculate delta and assign it as least distance if it is lower
					delta = result.position.x - rightmost_pos.x
					if delta < least_dist:
						least_dist = delta
		if least_dist != default_least_dist && least_dist > 0.1:
			target_pos = get_pos() + Vector2(least_dist, 0)
			start_movement(dir)

func roundvec2(v):
	return Vector2(int(round(v.x)), int(round(v.y)))

func start_movement(dir):
	if moving == null:
		if dir != previous_move:
			print("transition starting: " + dir)
			moving = dir
			previous_move = dir
			get_tree().call_group(2, "root", "generate_dynamic_collision", get_pos(), walkable)