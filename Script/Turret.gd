extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $StaticBody2D/CollisionShape2D

enum Type{SINGLE, LINE, SHOTGUN}

var health = 100
var scientist = null

var killed = false
var built = false

var type = 1

var shoot_delay = 1.0
var bullet_speed = 300

var bullet_speed_mod = 1.0
var build_speed:float = 2.0

var line_amount = 1.5
var line_delay = 0.6

var max_repair = 45

var shotgun_amount = 3

const turret_shoot = preload("res://assets/turret_shoot.ogg")
const metal_hit = preload("res://assets/metal_hit2.ogg")
const explode_no_power = preload("res://assets/explode_no_power.ogg")
const explode_power = preload("res://assets/explode_power.ogg")

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(position)
	$AnimatedSprite2D.frame = 0
	
	type = randi_range(0, 2)
	health = health + 7*Globals.difficulty
	max_repair = randf_range(0.95, 1.05) * (Globals.difficulty * 7 + max_repair + health)
	build_speed = clamp((build_speed + Globals.difficulty*0.05) * randf_range(0.95, 1.05),1,10.0) 
	bullet_speed_mod = (bullet_speed_mod + Globals.difficulty*0.03) * randf_range(0.95, 1.05)
	
	shotgun_amount = (3 + (floor(Globals.difficulty * 0.10) * 2.0) )
	line_amount = (1 + floor(Globals.difficulty * 0.35)) + randi_range(0, 2)
	line_delay = clamp((line_delay - Globals.difficulty*0.005) * randf_range(0.80, 1.2), 0.01, 2.0) / line_amount
	
	shoot_delay = clamp((shoot_delay - Globals.difficulty*0.006) * randf_range(0.90, 1.1), 0.1, 3.0)
	
	if type == Type.SHOTGUN:
		shoot_delay *= 2.2
	if type == Type.LINE:
		shoot_delay *= 1.5
	if type == Type.SINGLE:
		shoot_delay *= 1.3
		
	$AnimatedSprite2D.speed_scale = build_speed
	$Hitbox.set_collision_layer_value(7, false)
	
	#collision_shape_2d.disabled = true
	animated_sprite_2d.visible = false
	$EYE.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#self.position = Vector2(128 + randi_range(0, 256),128)
	pass

func build(scientist):
	self.scientist = scientist
	animated_sprite_2d.visible = true
	animated_sprite_2d.play("build")
	$Hitbox.set_collision_layer_value(7, true)
	#collision_shape_2d.disabled = false

func _on_animated_sprite_2d_animation_finished():
	$EYE.visible = true
	built = true
	get_parent().enemy_added(self)
	$ShootTimer.start(shoot_delay)
	#print("HA")
	heal()
	pass # Replace with function body.

func stop_building():
	$AnimatedSprite2D.pause()

func heal():
	while !is_broken() && is_instance_valid(scientist):
		await get_tree().create_timer(1).timeout
		health = health + 25
		health = clampi(health, 0, max_repair)

func _on_shoot_timer_timeout():
	
	match type:
		Type.SINGLE:
			print("SINGLE")
			shoot_single()
			return
		Type.LINE:
			print("LINE")
			shoot_line()
			return
		Type.SHOTGUN:
			print("SHOTGUN")
			shoot_shotgun()
			return

	pass # Replace with function body.

func shoot_shotgun():
	var bullet_params:BulletParams = BulletParams.new()
	bullet_params.speed = (200 + Globals.difficulty * 25) * bullet_speed_mod * 0.6
	bullet_params.size = (0.8 + Globals.difficulty * 0.1) * 0.8
	
	var player = get_tree().get_first_node_in_group("player")
	BulletManager.even_shotgun(self,
	 BulletManager.CollisionLayer.PLAYER,
	 self.global_position.direction_to(player.global_position).normalized() * bullet_speed * bullet_speed_mod,
	 shotgun_amount,
	 60,
	 0,
	 0,
	bullet_params)
#shooter, collision_layer, velocity, num, spread, speed_vary, slow_down

func shoot_line():
	var bullet_params:BulletParams = BulletParams.new()
	bullet_params.speed = (200 + Globals.difficulty * 25) * bullet_speed_mod
	bullet_params.size = 0.8 + Globals.difficulty * 0.1
	
	var player = get_tree().get_first_node_in_group("player")
	BulletManager.shoot_line(self,
	 BulletManager.CollisionLayer.PLAYER,
	 self.global_position.direction_to(player.global_position).normalized() * bullet_speed * bullet_speed_mod,
	 line_amount,
	 line_delay,
	bullet_params)

func shoot_single():
	var bullet_params:BulletParams = BulletParams.new()
	bullet_params.speed = (200 + Globals.difficulty * 25) * bullet_speed_mod * 0.7
	bullet_params.size = clamp((0.8 + Globals.difficulty * 0.2) * 2.0, 0, 8.0)
	
	var player = get_tree().get_first_node_in_group("player")
	BulletManager.shoot_line(self,
	 BulletManager.CollisionLayer.PLAYER,
	 self.global_position.direction_to(player.global_position).normalized() * bullet_speed * bullet_speed_mod,
	 1,
	 0.1,
	bullet_params)
	
func hit(hit_event:HitEvent):
	
	if hit_event.damage != 0:
		handle_damage(hit_event.damage)
		
func handle_damage(damage):
	#print(collision_shape_2d.disabled)
	self.health -= damage
	
	
	if health <= 0:
		
		if killed:
			return
			
		if built:
			var dedsound = FreeAudio.new(explode_power, -2)
			dedsound.pitch_scale = 1.0 + randf_range(-0.1, 0.1)
			get_parent().add_child(dedsound)
			get_parent().enemy_removed(position)
			killed = true
		else:
			if $AnimatedSprite2D.frame > 0:
				var dedsound = FreeAudio.new(explode_no_power, -6)
				dedsound.pitch_scale = 1.0 + randf_range(-0.1, 0.1)
				get_parent().add_child(dedsound)
				killed = true
				
		$SmokeParticles.emitting = true
		#collision_shape_2d.disabled = true
		$EYE.visible = false
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 0
		$ShootTimer.stop()
		$StaticBody2D.set_collision_mask_value(4, false)
		$StaticBody2D.set_collision_layer_value(2, false)
		$StaticBody2D.set_collision_layer_value(3, false)
		$Hitbox.set_collision_layer_value(7, false)
		
		return
		
	#var hitsound = FreeAudio.new(metal_hit, -5)
	$Hit.pitch_scale = 0.82 + randf_range(-0.1, 0.1)
	$Hit.play(0)
	$AnimatedSprite2D/AnimationPlayer.play("flash")
	#get_parent().add_child(hitsound)

func is_broken():
	if health <= 0:
		return true
	return false

func on_shoot():
	var hitsound = FreeAudio.new(turret_shoot, -5)
	#hitsound.pitch_scale = 0.2
	get_parent().add_child(hitsound)
	return

func _on_animated_sprite_2d_frame_changed():
	if health > 0:
		health += clamp((max_repair/4.0), 0, max_repair)
	pass # Replace with function body.
