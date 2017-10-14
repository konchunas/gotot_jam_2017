extends Node2D

func on_player_collide(player):
	if player.has_method("_die"):
		player._die()
		
func activate():
	get_node("animation").play("piston_pos")