extends KinematicBody2D

export var speed = 35

var current_rune = null

func _ready():
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	if Input.is_key_pressed(KEY_SHIFT):
		if Input.is_key_pressed(KEY_W):
			rune_check("up")
		if Input.is_key_pressed(KEY_S):
			rune_check("down")
		if Input.is_key_pressed(KEY_A):
			rune_check("left")
		if Input.is_key_pressed(KEY_D):
			rune_check("right")
		return
	if Input.is_key_pressed(KEY_W) || Input.is_key_pressed(KEY_UP):
		move(Vector2(0, -speed * delta))
	if Input.is_key_pressed(KEY_S) || Input.is_key_pressed(KEY_DOWN):
		move(Vector2(0, speed * delta))
	if Input.is_key_pressed(KEY_A) || Input.is_key_pressed(KEY_LEFT):
		move(Vector2(-speed * delta, 0))
	if Input.is_key_pressed(KEY_D) || Input.is_key_pressed(KEY_RIGHT):
		move(Vector2(speed * delta, 0))

func rune_check(dir):
	# check to see if we are standing on a rune - if we are, attempt the transition in that direction
	if current_rune != null:
		current_rune.attempt_transition(dir)

func change_parent(world):
	print("Character changed parent from " + get_parent().get_name() + " to " + world.get_name())
	var global_pos = get_global_pos()
	get_parent().remove_child(self)
	world.add_child(self)
	set_global_pos(global_pos)
	pass