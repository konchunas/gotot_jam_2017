extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func on_player_collide(player):
	player._die()
	get_node("../animation").seek(0)
