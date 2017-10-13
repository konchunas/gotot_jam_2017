extends KinematicBody2D

const GRAVITY = 200.0
const WALK_SPEED = 200

var velocity = Vector2()

func _fixed_process(delta):
	velocity.y += delta * GRAVITY
	if (Input.is_action_pressed("ui_left")):
		velocity.x = - WALK_SPEED
	elif (Input.is_action_pressed("ui_right")):
		velocity.x =   WALK_SPEED
	else:
		velocity.x = 0

	var motion = velocity * delta
	motion = move(motion)

	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)

		if get_collider():
			if get_collider().has_method("on_player_collide"):
				get_collider().on_player_collide(self)


func _ready():
	set_fixed_process(true)

func _die():
	set_pos(Vector2(10,10))