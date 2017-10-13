extends Timer

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	randomize()
	pass

func _on_timeout():
	if randi()%2 == 0:
		get_node("..").shoot()
	pass # replace with function body


func _on_laser_timeout_timeout():
	pass # replace with function body
