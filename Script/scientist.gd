extends CharacterBody2D

enum State{SETUP,ALERTED,IDLE,SCARED,BUILDING}

@onready var navigation_agent = $NavigationAgent2D

@onready var animated_sprite_2d = $AnimatedSprite2D

#const GUTSPLODE = preload("res://Scenes/gutsplode.tscn")
const BLOOD_PARTICLES = preload("res://Scenes/blood_particles.tscn")
const TURRET = preload("res://Scenes/Turret.tscn")
const hitsound = preload("res://assets/hit.ogg")

const gutsplode_sound = preload("res://assets/gutsplode.ogg")

var state = State.SETUP
var room = null
var player = null
var extra_vel:Vector2 = Vector2.ZERO
var movement_vel:Vector2 = Vector2.ZERO
var killed = false
var run_speed = 240


var blood_delay = false
var health = 200

var turret = null
var turret_pos = null

# Called when the n
#ode enters the scene tree for the first time.
func _ready():
	
	var parent = get_parent()
	room = parent.get_room()
	parent.enemy_added(self)
	
	
	run_speed = clamp(int((run_speed + Globals.difficulty * 6) * randf_range(0.8,1.2)), 100, 600)
	health = clamp(int((health + Globals.difficulty * 25) * randf_range(0.8,1.2)), 0, 1200)
	
	$AnimatedSprite2D.play("scared")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	$Label.text = str(health)
	
	if state == State.IDLE:
		if player.curr_room == self.room:
			run_away()
		return
	
	if state == State.BUILDING:
		velocity = Vector2.ZERO
		$AnimatedSprite2D.play("build")
		if self.position <= turret_pos:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		
	if state == State.SCARED:
		
		
		$AnimatedSprite2D.play("scared")
		$AnimatedSprite2D.speed_scale = 0.8
		#self.movement_vel = self.position.direction_to(player.position).normalized() * -1 * 100
		
		if turret_pos == null:
			create_turret()
			
		if navigation_agent.is_navigation_finished():
			state = State.BUILDING
			
		return
		
	if state == State.SETUP:
		player = get_player()
		state = State.IDLE
		
		return
		
	pass
	
	
func _physics_process(delta):
	
	if navigation_agent.is_navigation_finished():
		return
	
	if state == State.SCARED:
		var to_pos = navigation_agent.get_next_path_position()
		movement_vel = self.global_position.direction_to(to_pos).normalized() * run_speed
		
		#print("Pathing from: ", self.global_position, " to: ", to_pos)
		
	extra_vel = extra_vel.lerp(Vector2.ZERO, delta*10)
	#extra_vel = extra_vel.snapped(0.5)
	
	#print(extra_vel)

		
	if state != State.BUILDING:
		self.velocity = movement_vel + extra_vel
		if self.velocity.x < 0:
			$AnimatedSprite2D.flip_h = false
		elif self.velocity.x > 0:
			$AnimatedSprite2D.flip_h = true
		move_and_slide()
	
func run_away():
	
	if state == State.IDLE:
		state = State.ALERTED
	
	await get_tree().create_timer(0.1 + randf_range(0.1,0.2)).timeout
	
	if state == State.ALERTED:
		state = State.SCARED

func handle_damage(damage):
	self.health -= damage
	
	
	if state == State.IDLE || state == State.SCARED || state == State.ALERTED:
		#print("b ", state)
		state = State.SCARED
		#print(state)
	
	
	var blood_particle = null
	if !blood_delay:
		blood_particle = BLOOD_PARTICLES.instantiate()
		blood_particle.position = self.position
	
	if health <= 0:
		if killed:
			return
			
		killed = true
		
		blood_particle = BLOOD_PARTICLES.instantiate()
		blood_particle.position = self.position
		blood_particle.amount = blood_particle.amount*4
		blood_particle.bigger(2)
		blood_particle.faster(3)
		blood_particle.lifetime = blood_particle.lifetime
		
		var gutsplode = FreeAudio.new(gutsplode_sound, 5)
		
		get_parent().add_child(gutsplode)
		get_parent().enemy_removed(position)
		
		if turret:
			turret.stop_building()
			
		queue_free()
	else:
		if !blood_delay:
			var hitsound = FreeAudio.new(hitsound, 4)
			hitsound.pitch_scale = 0.82 + randf_range(-0.1, 0.1)
			get_parent().add_child(hitsound)
	
		
	if !$AnimatedSprite2D/FlashAnim.is_playing():
		$AnimatedSprite2D/FlashAnim.play("flash")
	
	if !blood_delay:
		blood_delay = true
		blood_delay_start()
	if blood_particle:
		get_parent().add_child(blood_particle)
	
func blood_delay_start():
	await get_tree().create_timer(0.05).timeout
	blood_delay = false
	
func get_player():
	player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("null player in: ", self)
		queue_free()
		
	return player
	
func hit(hitevent:HitEvent):
	if hitevent.knockback_strength != 0:
		#print("hit: ", extra_vel)
		self.extra_vel += hitevent.knockback_dir * hitevent.knockback_strength
	
	if hitevent.damage != 0:
		handle_damage(hitevent.damage)
		
func is_within_dist_turrets(pos, radius):
	for turrets in room.turrets:
		#print(turrets.position.distance_to(pos))
		if turrets.global_position.distance_to(pos) <= radius:
			return true
	return false

func create_turret():
	var region_outline = room.navigation_region.navigation_polygon.get_outline(0)

	#print(region_outline)

	var min = region_outline[0] + room.position #+ Vector2(64,64)
	var max = region_outline[2] + room.position #- Vector2(64,64)
	
	#if player.global_position >= global_position:
		#max.x = self.position.x + room.position.x
	#
	#if player.global_position < global_position:
		#min.x = self.position.x + room.position.x
		
	#var middle = room.get_middle() + room.global_position
	#if player.global_position.y < middle.y:
	var dire = Vector2(1,0)
	if player.prev_room:
		dire = player.prev_room.get_dir_to_room(room)
	
	#print("direct ", dire)
	
	if dire.x == 1:
		min.x = self.position.x + room.position.x
	elif dire.x == -1:
		max.x = self.position.x + room.position.x
	elif dire.y == 1:
		min.y = self.position.y + room.position.y
	elif dire.y == -1:
		max.y = self.position.y + room.position.y
	
	min += Vector2(64,64) * 1
	max -= Vector2(64,64) * 1
	#print("min: ", min, "max: ", max)
	
	var num_tries = 0
	while true:
		num_tries += 1
		turret_pos = Vector2(randi_range(min.x, max.x), randi_range(min.y,max.y))
			#self.movement_vel = self.position.direction_to(turret_pos).normalized() * -1 * 100
		
		#var new_target_pos = turret_pos + turret_pos.direction_to(self.position) * 20
		#var new_target_pos = turret_pos + Vector2(48,-48)
		
		var new_target_pos = turret_pos
		
		if self.global_position < turret_pos:
			new_target_pos -= Vector2(32,0)
		else:
			new_target_pos += Vector2(32,0)
			
		navigation_agent.target_position = new_target_pos
		
		if navigation_agent.is_target_reachable():
			
			if !is_within_dist_turrets(turret_pos, 100):
				break
		await get_tree().create_timer(num_tries * 0.05).timeout
	#print(navigation_agent.target_position)
	
	var n_turret = TURRET.instantiate()
	turret = n_turret
	room.turrets.append(n_turret)
	n_turret.position = turret_pos - room.position
	
	#print(n_turret.global_position)
	get_parent().add_child(n_turret)

func _on_navigation_agent_2d_navigation_finished():
	if turret:
		turret.build(self)
	else:
		create_turret()
	pass # Replace with function body.
