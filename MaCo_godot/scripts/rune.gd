extends Area2D

var parent_world

func _ready():
	parent_world = get_parent()
	pass

func _on_rune_body_enter(body):
	if body.get_name() == "character":
		body.current_rune = self
	pass

func _on_rune_body_exit( body ):
	if body.get_name() == "character":
		body.current_rune = null
	pass

func attempt_transition(dir):
	parent_world.begin_transition(dir)