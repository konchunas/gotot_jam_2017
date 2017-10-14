extends StaticBody2D

func _ready():
	pass

func on_player_collide(player):
	player._die()
	get_node("..").stop_shooting()
