extends Node2D

func _ready():
	pass
	
func shoot():
	get_node("animation").play("shoot")
	get_node("laser_timeout_timer").start()
	get_node("laser_random_timer").stop()

func stop_shooting():
	get_node("laser_timeout_timer").stop()
	get_node("laser_random_timer").start()
	get_node("animation").seek(0, true)
	get_node("animation").stop()


