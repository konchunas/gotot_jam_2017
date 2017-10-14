extends Area2D

export(NodePath) var target

func _on_body_enter( body ):
	if target:
		if get_node(target).has_method("activate"):
			get_node(target).activate()
