extends Node2D

var follow_target

func _ready():
	follow_target = get_parent().get_node("worlds/world_1/character")
	set_process(true)
	pass

func _process(delta):
	set_global_pos(follow_target.get_global_pos())