extends RigidBody2D

var initial_gravity_scale
var initial_pos = Vector2()
var previousLinearVelocity = Vector2()
var previousAngularVelocity = 0.0
var prev_bounce = 0.0
var jump_power = 150
var last_collide_time = 0
var idle_time = 0
var prev_pos = Vector2()
var is_sticking = false

# var local_collision_pos = Vector2()
var should_stick = false
var sticked_to
var last_touched_pos = Vector2()
var last_stick_pos = Vector2()
var last_stick_time = 0

var glazing_trail_particle = "../follower/glazing_trail"

func _ready():
	set_fixed_process(true)
	set_process_input(true)
	initial_gravity_scale = get_gravity_scale()
	initial_pos = get_pos()

func _integrate_forces( state ):
	var face = get_node("../follower")
	#if get_pos().distance_to(last_stick_pos) < 700:
	should_stick = false
	var i = 0
	while i < state.get_contact_count():  #this check is needed or it will throw errors 			
		last_touched_pos = state.get_contact_collider_pos(i)
		var angle = face.get_angle_to(state.get_contact_local_pos(i))
		if angle > 1.5 : 
			should_stick = true
			last_stick_time = OS.get_ticks_msec()
			sticked_to = state.get_contact_collider_object(i)
			last_stick_pos = state.get_contact_collider_pos(i)
		i += 1
	

func _fixed_process(delta):
	
	# release from sticking
	if not Input.is_action_pressed("ui_accept") or (not should_stick and OS.get_ticks_msec() - last_stick_time > 1000):
		if get_gravity_scale() == 0.0: # if we were touching ceiling and released space than continue moving
			print("UNSTICK")
			get_node("sound").stop_all()
			is_sticking = false
			set_gravity_scale(initial_gravity_scale)
			set_bounce(prev_bounce)
			set_linear_velocity(previousLinearVelocity)
			set_angular_velocity(previousAngularVelocity)
			set_linear_damp(-1)
			get_node(glazing_trail_particle).set_emitting(false)


	var v = get_linear_velocity()
	var pos_diff = (prev_pos - get_pos()).abs()
	
	if pos_diff.x < 0.5 and pos_diff.y < 0.5 and not should_stick:
		idle_time += delta
	else:
		idle_time = 0
	
	# idle death after 1 sec
#	if idle_time > 1:
#		_die()
#		print("idle die")	
#		# falling death
	
	if (OS.get_ticks_msec() - last_collide_time > 3000 and v.y > 4000 and abs(v.y) > abs(v.x)*2.0):
		_die()
		print("falling die ", v.y)
		
	prev_pos = get_pos()

func _input(event):
	#print(get_pos().distance_to(last_touched_pos))
	if event.is_action_pressed("ui_accept") and get_pos().distance_to(last_touched_pos) < 300 : #on ground	   
		apply_impulse(Vector2(0,0), Vector2(1000, -jump_power*get_weight() ))
		switch_to_jump_face(true)
	if event.is_action_pressed("ui_focus_next"):
		shoop_da_woop(true)
	if event.is_action_released("ui_focus_next"):
		shoop_da_woop(false)
		
func shoop_da_woop(is_shoop):
	switch_to_jump_face(is_shoop)
	var laser = get_node("../follower/Laser")
	laser.set_hidden(!is_shoop)
	if is_shoop:
		laser.shoot()
	else:
		laser.stop_shooting()
		
func death_by_lazer():
	_die()

func _die():
	
	if not get_node("death_animations").is_playing():
		get_node("sound").play("death_on_spikes")
		get_node("death_animations").play("imploding")
	
	print("die")

func switch_to_jump_face(is_floor):
	get_node("../follower/idle_face").set_hidden(is_floor)
	get_node("../follower/jumping_face").set_hidden(!is_floor)

func _on_body_enter( body ):
	
	if last_collide_time and OS.get_ticks_msec() - last_collide_time > 400:
		get_node("sound").play("collision_with_floor")
		play_wiggle_anim()
		switch_to_jump_face(false)
	
	last_collide_time = OS.get_ticks_msec()
	
	if body.has_method("on_player_collide"):
		body.on_player_collide(self)

	if should_stick:
		on_hit_ceiling(body)

	if Input.is_action_pressed("ui_accept") and should_stick:
		print("stick")
		is_sticking = true
		get_node("sound").play("friction")
		previousLinearVelocity = get_linear_velocity()
		previousAngularVelocity = get_angular_velocity()
		prev_bounce = get_bounce();
		set_linear_velocity(Vector2(0, 0))
		set_angular_velocity(0)
		set_bounce(0.0)
		set_gravity_scale(0.0)

		var slidingImpulse = Vector2()
		slidingImpulse.y = get_weight()
		slidingImpulse.x = sqrt( previousLinearVelocity.x * previousLinearVelocity.x + previousLinearVelocity.y * previousLinearVelocity.y )
		slidingImpulse = slidingImpulse.rotated(body.get_rot())
		set_linear_velocity(slidingImpulse)
		set_linear_damp(0.9)	
	

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