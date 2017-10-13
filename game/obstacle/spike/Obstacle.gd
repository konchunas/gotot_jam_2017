extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	pass


func _on_contact( body ):
	body._die()
	pass # replace with function body

func _on_body_enter( body ):
	body._die()
	pass # replace with function body
	
func on_player_collide(player):
	player._die()
