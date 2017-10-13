extends StaticBody2D

func _ready():
	set_fixed_process(true)

func on_player_collide(player):
	player._die()
