extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export(NodePath) var target_path
var target

func _ready():
	if target_path:
		target = get_node(target_path)
		set_process(true)
	
func _process(delta):
	set_pos(target.get_pos())