extends CharacterBody2D

enum State{SETUP,ALERTED,IDLE,SCARED,BUILDING}

@onready var navigation_agent = $NavigationAgent2D

@onready var animated_sprite_2d = $AnimatedSprite2D

const GUTSPLODE = preload("res://Scenes/gutsplode.tscn")
const BLOOD_PARTICLES = preload("res://Scenes/blood_particles.tscn")
const TURRET = preload("res://Scenes/Turret.tscn")

var state = State.SETUP
var room = null
var player = null
var extra_vel:Vector2 = Vector2.ZERO
var movement_vel:Vector2 = Vector2.ZERO

var health = 200

var turret_pos = null

# Called when the n
#ode enters the scene tree for the first time.
func _ready():
	if get_parent().has_method("get_room"):
		room = get_parent().get_room()
	
	animated_sprite_2d.play("idle")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if state == State.IDLE:
		if player.current_room == self.room:
			run_away()
		return
	
	if state == State.BUILDING:
		$AnimatedSprite2D.play("build")
		
	if state == State.SCARED:
		
		
		$AnimatedSprite2D.play("scared")
		$AnimatedSprite2D.speed_scale = 0.8
		#self.movement_vel = self.position.direction_to(player.position).normalized() * -1 * 100
		
		if turret_pos == null:
			var region_outline = room.navigation_region.navigation_polygon.get_outline(0)

			#print(region_outline)

			var min = region_outline[0] + room.position
			var max = region_outline[2] + room.position
			
			print("min: ", min, "max: ", max)
			
			while true:
				turret_pos = Vector2(randi_range(min.x, max.x), randi_range(min.y,max.y))
					#self.movement_vel = self.position.direction_to(turret_pos).normalized() * -1 * 100
					
				navigation_agent.target_position = turret_pos
				
				if navigation_agent.is_target_reachable():
					break
			
			#print(navigation_agent.target_position)
			
			var n_turret = TURRET.instantiate()
			n_turret.global_position = turret_pos
			get_parent().add_child(n_turret)
			
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
		movement_vel = self.global_position.direction_to(to_pos).normalized() * 100
		
		#print("Pathing from: ", self.global_position, " to: ", to_pos)
		
	extra_vel = extra_vel.lerp(Vector2.ZERO, delta*10)
	#extra_vel = extra_vel.snapped(0.5)
	
	#print(extra_vel)
	
	self.velocity = movement_vel + extra_vel
	if self.velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif self.velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		
	if state != State.BUILDING:
		move_and_slide()
	
func run_away():
	
	state = State.ALERTED
	
	await get_tree().create_timer(1.0).timeout
	
	state = State.SCARED

func handle_damage(damage):
	self.health -= damage
	
	var blood_particle = BLOOD_PARTICLES.instantiate()
	blood_particle.position = self.position
	
	if health <= 0:
		blood_particle.amount = blood_particle.amount*4
		blood_particle.bigger(2)
		blood_particle.faster(3)
		blood_particle.lifetime = blood_particle.lifetime
		get_parent().add_child(GUTSPLODE.instantiate())
		
		queue_free()
		
	$Hit.play(0)
		
	if !$AnimatedSprite2D/FlashAnim.is_playing():
		$AnimatedSprite2D/FlashAnim.play("flash")
		
	get_parent().add_child(blood_particle)
	
	if state == State.IDLE || state == State.SCARED:
		state == State.SCARED

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
