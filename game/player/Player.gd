extends RigidBody2D

const GRAVITY = 200.0
const WALK_SPEED = 200

var velocity = Vector2()
var initial_gravity_scale
var initial_pos = Vector2()

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	initial_gravity_scale = get_gravity_scale()
	initial_pos = get_pos()

func _fixed_process(delta):
	# if not Input.is_action_pressed("ui_select"):
	# 	if old_gravity_scale != 0.0:
	# 		set_gravity_scale(old_gravity_scale)
	pass
		 
func _input(event):
	if event.is_action_released("ui_select"):
		set_gravity_scale(initial_gravity_scale)

func _die():
	set_pos(initial_pos)

func _on_body_enter( body ):
	if Input.is_action_pressed("ui_select"):
		if body.is_in_group("ceiling"):
#			set_linear_velocity(Vector2(0, 0))
			set_angular_velocity(0)
			set_gravity_scale(0)
		elif body.is_in_group("floor"):
			apply_impulse(Vector2(0,0), Vector2(0, -700))

	

	if body.has_method("on_player_collide"):
		body.on_player_collide(self)
