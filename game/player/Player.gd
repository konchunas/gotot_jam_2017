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
var last_collide_time = 0
var idle_time = 0
var prev_pos = Vector2()
var should_stick = false

var glazing_trail_particle = "../follower/glazing_trail"

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	initial_gravity_scale = get_gravity_scale()
	initial_pos = get_pos()

func _integrate_forces( state ):
	var face = get_node("../follower")
	if not should_stick:
		var i = 0
		while i < state.get_contact_count():  #this check is needed or it will throw errors 			
			var angle = face.get_angle_to(state.get_contact_local_pos(i))
			if angle > 1.5 : 
				should_stick = true
			i += 1


func _fixed_process(delta):
	
	if not Input.is_action_pressed("ui_select"):
		should_stick = false
	
	var v = get_linear_velocity()
	var pos_diff = (prev_pos - get_pos()).abs()
	
	if pos_diff.x < 0.5 and pos_diff.y < 0.5 and not should_stick:
		idle_time += delta
	else:
		idle_time = 0
	
	# idle death after 1 sec
	if idle_time > 1:
		_die()
		print("idle die")	
		# falling death
	if (last_collide_time > 0 and OS.get_ticks_msec() - last_collide_time > 1000 and v.y > 2000 and abs(v.y) > abs(v.x)*2.0):
		_die()
		print("falling die ", v.y)
		
	prev_pos = get_pos()
	pass
		 
func _input(event):
	if event.is_action_released("ui_select"):
		if get_gravity_scale() == 0.0:		# if we were touching ceiling and released space than continue moving
			set_gravity_scale(initial_gravity_scale)
			set_linear_velocity(previousLinearVelocity)
			set_angular_velocity(previousAngularVelocity)
			set_linear_damp(0.0)
			get_node(glazing_trail_particle).set_emitting(false)

func death_by_lazer():
	_die()

func _die():
	if not get_node("death_animations").is_playing():
		get_node("death_animations").play("imploding")

func _on_body_enter( body ):
	
	if last_collide_time and OS.get_ticks_msec() - last_collide_time > 400:
		get_node("sound").play("collision_with_floor")
		play_wiggle_anim()
	
	
	last_collide_time = OS.get_ticks_msec()
	
	if body.has_method("on_player_collide"):
		body.on_player_collide(self)

	if Input.is_action_pressed("ui_select"):
		if body.is_in_group("ceiling") or should_stick:
			previousLinearVelocity = get_linear_velocity()
			previousAngularVelocity = get_angular_velocity()
			set_linear_velocity(Vector2(0, 0))
			set_angular_velocity(0)

			var slidingImpulse = Vector2()
			slidingImpulse.x = sqrt( previousLinearVelocity.x * previousLinearVelocity.x + previousLinearVelocity.y * previousLinearVelocity.y )
			slidingImpulse = slidingImpulse.rotated(body.get_rot())
			set_linear_velocity(slidingImpulse)
			set_linear_damp(0.9)

			set_gravity_scale(0.0)
			on_hit_ceiling(body)
		else:
			apply_impulse(Vector2(0,0), Vector2(jump_power * get_gravity_scale() * 0.5, -jump_power * get_gravity_scale() ))
	

func on_hit_ceiling(ceiling):
	emit_rotated_particle("../follower/ceil_bump_particles", ceiling.get_rot())
	emit_rotated_particle(glazing_trail_particle, ceiling.get_rot())
	play_wiggle_anim()
	
func emit_rotated_particle(nodePath, angle):
	var particles = get_node(nodePath)
	particles.set_rot(angle)
	particles.set_emitting(true)

func play_wiggle_anim():
	get_node("animations").play("wiggling")

func _on_death_animations_finished():
	set_linear_velocity(Vector2(0, 0))
	set_angular_velocity(0)
	set_pos(initial_pos)
	get_node("../follower").set_scale(Vector2(1,1))
	get_node("circle").set_scale(Vector2(1,1))
	idle_time = 0
	last_collide_time = 0
	pass # replace with function body
