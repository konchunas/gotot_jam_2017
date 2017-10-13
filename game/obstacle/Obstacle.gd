extends Node2D

func _ready():
	set_fixed_process(true)

func on_player_collide(player):
	if player.has_method("_die"):
		player._die()

func on_body_enter( player ):
	on_player_collide(player)
