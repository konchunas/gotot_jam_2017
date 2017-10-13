extends RigidBody2D

const GRAVITY = 200.0
const WALK_SPEED = 200

var velocity = Vector2()
var initial_gravity_scale
var initial_pos = Vector2()
var previousLinearVelocity = Vector2()
var previousAngularVelocity = 0.0
export var jump_power = 70
export var sliding_power = 200

var glazing_trail_particle = "../follower/glazing_trail"

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	initial_gravity_scale = get_gravity_scale()
	initial_pos = get_pos()

func _fixed_process(delta):
	pass
		 
func _input(event):
	if event.is_action_released("ui_select"):
		if get_gravity_scale() == 0.0:		# if we were touching ceiling and released space than continue moving
			set_gravity_scale(initial_gravity_scale)
			set_linear_velocity(previousLinearVelocity)
			set_angular_velocity(previousAngularVelocity)
			get_node(glazing_trail_particle).set_emitting(false)

func death_by_lazer():
	_die()

func _die():
	set_linear_velocity(Vector2(0, 0))
	set_angular_velocity(0)
	set_pos(initial_pos)

func _on_body_enter( body ):

	if body.has_method("on_player_collide"):
		body.on_player_collide(self)

	if Input.is_action_pressed("ui_select"):
		if body.is_in_group("ceiling"):
			previousLinearVelocity = get_linear_velocity()
			previousAngularVelocity = get_angular_velocity()
			set_linear_velocity(Vector2(0, 0))
			set_angular_velocity(0)

			var slidingImpulse = Vector2()
			slidingImpulse.x = sliding_power
			slidingImpulse = slidingImpulse.rotated(body.get_rot())
			apply_impulse(Vector2(0,0), slidingImpulse)
			set_linear_damp(0.9)
			

			set_gravity_scale(0.0)
			on_hit_ceiling(body)
		else:
			apply_impulse(Vector2(0,0), Vector2(0, -jump_power * get_gravity_scale() ))

func on_hit_ceiling(ceiling):
	var bump_particles = get_node("../follower/ceil_bump_particles")
	bump_particles.set_rot(ceiling.get_rot())
	bump_particles.set_emitting(true)
	emit_rotated_particle(glazing_trail_particle, ceiling.get_rot())
	get_node("wiggling_anim").play("wiggling")
	
func emit_rotated_particle(nodePath, angle):
	var particles = get_node(nodePath)
	particles.set_rot(angle)
	particles.set_emitting(true)