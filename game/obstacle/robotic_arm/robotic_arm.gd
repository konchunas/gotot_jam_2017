extends Node2D

func _ready():
	var anim = get_node("animation").get_animation("piston_pos")
	anim.set_loop(true)
	get_node("animation").play("piston_pos")

func on_player_collide(player):
	if player.has_method("_die"):
		player._die()
		
func activate():
	get_node("animation").play("piston_pos")