extends CenterContainer

func _ready():
	set_process_input(true)
	pass

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_node("AnimationPlayer").advance(1)