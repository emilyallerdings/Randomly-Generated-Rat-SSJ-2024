extends CharacterBody2D
class_name Player

signal on_death

@onready var crosshair = $Crosshair
@onready var energy_bar = $Energy_Bar/EnergyBar
#@onready var camera_2d = $Camera2D
#@onready var anim_sprite = $AnimSprite
@onready var flash = $Flash

var invincible = false

const descriptions = [[],[],[]]
var upgrades_since_mutation = 0
					
var vec_to_crosshair

@onready var hearts_container = $CanvasLayer/HeartsContainer

var bulletparams:BulletParams = BulletParams.new()

#const BELCH_EFFECT = preload("res://Scenes/BelchEffect.tscn")

const BELCH_EFFECT = preload("res://resources/BelchEffect.tres")

const BULLET = preload("res://Scenes/bullet.tscn")

@onready var ENERGY_COLOR = $Energy_Bar/EnergyBar.color

var ELEC_COLOR:Color = Color(0,1,3,1)
var ACID_COLOR:Color = Color(0,1,0,1)

const MAX_ENERGY:float = 100

var sprinting = false
var speed = 400.0
var energy:float = MAX_ENERGY
var extra_velocity:Vector2 = Vector2(0,0)

var energy_cost = 50
var shoot_delay = 10

#var energy_coeff = 1.0

var shoot_type = 1
var stomach_type = 1
var feet_type = 1

var charge_rate = 10
var charge_coeff = 1.0

var bullet_dmg = 50
var damage_coeff = 1.0

var traction = 6
var traction_coeff = 1.0

var speed_coeff = 1.0

var bullet_scale_coeff = 1.0

var bullet_speed = 1000
var bullet_speed_coeff = 1.0

var curr_room = null
var prev_room = null

var knockback_factor = 1.0

var coeffs = []

var in_menu = false



func update_weapon(type:int = -1):
	if type != -1:
		shoot_type = type
	update_values()

func update_stomach(type:int = -1):
	if type != -1:
		stomach_type = type
	update_values()

func update_feet(type:int = -1):
	if type != -1:
		feet_type = type
	update_values()

func update_values():
	
	knockback_factor = 1.0
	$CanvasLayer/Stats/Weapon.text = "Weapon: " + Globals.titles[0][shoot_type-1]
	$CanvasLayer/Stats/Stomach.text = "Stomach: " + Globals.titles[1][stomach_type-1]
	$CanvasLayer/Stats/Feet.text = "Feet: " + Globals.titles[2][feet_type-1]
	
	$CanvasLayer/Stats/WeaponDesc.text = Globals.descriptions[0][shoot_type-1]
	$CanvasLayer/Stats/StomachDesc.text = Globals.descriptions[1][stomach_type-1]
	$CanvasLayer/Stats/FeetDesc.text = Globals.descriptions[2][feet_type-1]
	
	if shoot_type == 1:
		#$CanvasLayer/Stats/Weapon.text = "Weapon: Charged Spit Accelerator"
		#$CanvasLayer/Stats/WeaponDesc.text = charged_desc
		charge_rate = 150 * charge_coeff
		bullet_dmg = 48 * damage_coeff
		traction = 25 * traction_coeff
		bulletparams.size = 1.5
		bulletparams.speed = 1300
		bulletparams.color = ELEC_COLOR
		
	if shoot_type == 2:
		#$CanvasLayer/Stats/Weapon.text = "Weapon: Rocket Barf"
		#$CanvasLayer/Stats/WeaponDesc.text = rocket_desc
		bullet_dmg = 15 * damage_coeff
		charge_rate = 50 * charge_coeff
		traction = 8 / traction_coeff
		bulletparams.size = 1.0
		bulletparams.speed = 700
		bulletparams.color = ACID_COLOR
		
	if shoot_type == 3:
		#$CanvasLayer/Stats/Weapon.text = "Weapon: Rocket Barf"
		#$CanvasLayer/Stats/WeaponDesc.text = rocket_desc
		bullet_dmg = 20 * damage_coeff
		charge_rate = 100 * charge_coeff
		traction = 20 * traction_coeff
		bulletparams.size = 0.9
		bulletparams.speed = 1100
		bulletparams.color = ACID_COLOR


	if stomach_type == 1:
		#$CanvasLayer/Stats/Stomach.text = "Stomach: Belch Bubble"
		#$CanvasLayer/Stats/StomachDesc.text = belch_desc
		bulletparams.size *= 1.5
		bulletparams.speed *= 0.5
		bulletparams.slowdown = 2
		bulletparams.sway = 32
		bulletparams.spread = 30
		bulletparams.death_effect = BELCH_EFFECT
		bullet_dmg *= 0.75

	if stomach_type == 2:
		#$CanvasLayer/Stats/Stomach.text = "Stomach: Internal Combustion Guts"
		#$CanvasLayer/Stats/StomachDesc.text = combust_desc
		bulletparams.color
		bulletparams.size *= 0.6
		bulletparams.speed *= 0.9
		bullet_dmg *= 1.2
		bulletparams.slowdown = 0
		bulletparams.sway = 0
		bulletparams.spread = 3
		bulletparams.death_effect = null
		
	if feet_type == 1:
		#$CanvasLayer/Stats/Feet.text = "Feet: Webbed Feet"
		#$CanvasLayer/Stats/FeetDesc.text = feet_webbed_desc
		knockback_factor = 0.6
		traction *= 1.2
		bulletparams.spread = max(0, bulletparams.spread - 5)
	
	if feet_type == 2:
		#$CanvasLayer/Stats/Feet.text = "Feet: Thruster Feet"
		#$CanvasLayer/Stats/FeetDesc.text = reverse_feet_desc
		knockback_factor = -1.0	
		bullet_dmg * 0.95
		
	if feet_type == 3:
		#$CanvasLayer/Stats/Feet.text = "Feet: Acid Storing Legs"
		#$CanvasLayer/Stats/FeetDesc.text = feet_acid_desc
		knockback_factor = 1.05
		traction * 0.95
		bullet_dmg * 1.05
		charge_rate * 1.05
		bulletparams.size += 0.1
		bulletparams.spread += 5

	bulletparams.damage = bullet_dmg
	bulletparams.size *= bullet_scale_coeff	
	bulletparams.speed *= bullet_speed_coeff
	
	$CanvasLayer/Stats/damage_coeff.text = "Damage: " + str(damage_coeff).pad_decimals(2)
	$CanvasLayer/Stats/bullet_scale_coeff.text = "Bullet Size: " + str(bullet_scale_coeff).pad_decimals(2)
	$CanvasLayer/Stats/bullspeed_coeff.text = "Bullet Speed: " + str(bullet_speed_coeff).pad_decimals(2)
	$CanvasLayer/Stats/charge_coeff.text = "Charge Speed: " + str(charge_coeff).pad_decimals(2)
	$CanvasLayer/Stats/traction_coeff.text = "Traction: " + str(traction_coeff).pad_decimals(2)
	$CanvasLayer/Stats/speed_coeff.text = "Rat Speed: " + str(speed_coeff).pad_decimals(2)
	

func init_coeff(range):
	return randf_range(1.0 - range ,1.0 + range)

func _ready():
	
	$Rat/RatUpper.frame = 0
	
	hearts_container.add_heart()
	hearts_container.add_heart()
	hearts_container.add_heart()
	
	#anim_sprite.play("default")
	
	coeffs.resize(6)
	coeffs.fill(0.9)
	
	for index1 in range(0, coeffs.size()):
		var val = randf_range(-0.2, 0.2)
		var index2 = randi_range(0, coeffs.size()-1)
		
		while(index1 == index2 || coeffs[index2] - abs(val) < 0.5 || coeffs[index1] - abs(val) < 0.5 ):
			val = randf_range(-0.2, 0.2)
			index2 = randi_range(0, coeffs.size()-1)
			
		coeffs[index1] += val
		coeffs[index2] -= val
	
	var total = 0.0
	for coeff in coeffs:
		total += coeff
	print(total)
	
	bullet_scale_coeff = coeffs[0]
	charge_coeff = coeffs[1]
	damage_coeff = coeffs[2]
	traction_coeff = coeffs[3]
	speed_coeff = coeffs[4]
	bullet_speed_coeff	= coeffs[5]
	
	#var rand_diff = 0.2
	#
	#
	#bullet_scale_coeff = init_coeff(0.05)
	#charge_coeff = init_coeff(0.1)
	#damage_coeff = init_coeff(0.1)
	#traction_coeff = init_coeff(0.2)
	#speed_coeff = init_coeff(0.1)
	
	update_weapon(randi_range(1,3))
	#update_weapon(3)
	update_stomach(randi_range(1,2))
	update_feet(randi_range(1,3))
	$Hitbox.set_collision_layer_value(8, true)
	return

func _physics_process(delta):

	if in_menu:
		return

	var direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = Vector2.ZERO
	
	#if extra_velocity.length() < 100:
	#	velocity = direction.normalized() * SPEED
	
	#velocity = direction.normalized() * SPEED
	
	direction = direction.normalized() * speed
	
	if sprinting:
		direction *= 1.5
	
	var vel_dif = direction.dot(extra_velocity.normalized())
	if vel_dif < 0 && extra_velocity.length() > 100:
		direction -= vel_dif*extra_velocity.normalized()
		direction * 0.25
		
	
	velocity += direction * speed_coeff * 1.2
	
	velocity += extra_velocity
	extra_velocity = extra_velocity.lerp(Vector2.ZERO, delta * traction)
	
	if extra_velocity.length() < 30 && shoot_type == 2 && $Hitbox.get_collision_layer_value(7):
		print("Set to false")
		$Hurtbox.set_collision_mask_value(7, false)
	if extra_velocity.length() < 30:
		$Hitbox.set_collision_layer_value(8, true)
		
	
	
	move_and_slide()
	#self.position = position.snapped(Vector2(0.5, 0.5))
	if direction.length() > 0 && velocity.length() > 0:
		$Rat/Rat2.play("default")
	else:
		$Rat/Rat2.stop()	
		
func _process(delta):
	$CanvasLayer/Label3.text = "Floor: " + str(Globals.floor_num)
	if in_menu:
		return
	
	$CanvasLayer/Stats/CurrentDiff.text = "Difficulty: " + str(Globals.difficulty)
	
	crosshair.position = get_local_mouse_position()
	vec_to_crosshair = (crosshair.global_position - self.global_position).normalized()
	
	energy = clamp(energy+charge_rate*delta, 0, 100)
	energy_bar.scale.x = energy/MAX_ENERGY
	if energy < MAX_ENERGY:
		energy_bar.color = Color.DARK_RED
	else:
		energy_bar.color = ENERGY_COLOR
	
	var mouse_pos = get_global_mouse_position()
	#camera_2d.offset.x = round((mouse_pos.x - global_position.x) / (1920.0 / 2.0) * 150)
	#camera_2d.offset.y = round((mouse_pos.y - global_position.y) / (1080.0 / 2.0) * 150)
	
	
	
	if mouse_pos < self.global_position:
		$Rat/RatUpper.animation = "default2"
		$Rat.scale.x = 1
		#$Rat.look_at(mouse_pos)
		#$Rat.rotation += deg_to_rad(180)
	else:
		$Rat/RatUpper.animation = "default"
		$Rat.scale.x = -1
		#$Rat.look_at(mouse_pos)
	#camera_2d.global_position = camera_2d.global_position.round()
	
	#var direction = Input.get_vector("left", "right", "up", "down")
	#if direction.x > 0:
		#$SpriteUpper.play("front_right")
		#$Arm.play("front_right")
	#elif direction.x < 0:
		#$SpriteUpper.play("front_left")
		#$Arm.play("front_left")
	#elif direction.x == 0:
		#$SpriteUpper.stop()
	
func _input(event):
	if event.is_action_pressed("shoot"):
		
		if energy < MAX_ENERGY:
			$NoEnergy.play(0)
		
		shoot()
		shoot_loop()

func shoot_anim():
	await get_tree().create_timer(0.28).timeout
	$Rat/RatUpper.frame = 0

func shoot():
		
		if vec_to_crosshair == null:
			return
	
		if energy < MAX_ENERGY:
			return
		energy -= MAX_ENERGY
		#$AudioStreamPlayer.play()
		#BulletManager.create_bullet(self, BulletManager.CollisionLayer.ENEMY, vec_to_crosshair*1500, 25, self.global_position)
		#var bp:BulletParams = BulletParams.new()
		#damage_coeff = 2.0
		#bullet_scale_coeff = 5.0
		
		$Rat/RatUpper.frame = 1
		
		shoot_anim()
		
		if shoot_type == 3:
			var num_bullets = 3 + 2*round(damage_coeff*bulletparams.damage/20)
			#shooter, collision_layer, velocity, num, spread, speed_vary, slow_down
			BulletManager.even_shotgun(self, BulletManager.CollisionLayer.ENEMY, vec_to_crosshair,
			 num_bullets,  num_bullets * 5 + 5*bulletparams.size,
			 0, 0, bulletparams)
			#DebugDraw2D.line(self.position, self.position + (vec_to_crosshair * self.global_position.distance_to(crosshair.global_position)), Color.RED, 3, 0.5)
			extra_velocity += vec_to_crosshair * -1 * 2000 * knockback_factor
			get_tree().root.add_child(FreeAudio.new(preload("res://assets/spit.ogg")))
			#$Hitbox.set_collision_layer_value(8, false)
			#$Hurtbox.set_collision_mask_value(7, true)
		
		
		if shoot_type == 2:
			BulletManager.shotgun(self, BulletManager.CollisionLayer.ENEMY, vec_to_crosshair*1500,
			 10, 35, 500, 0, bulletparams)
			#DebugDraw2D.line(self.position, self.position + (vec_to_crosshair * self.global_position.distance_to(crosshair.global_position)), Color.RED, 3, 0.5)
			extra_velocity += vec_to_crosshair * -1 * 3000 * knockback_factor
			get_tree().root.add_child(FreeAudio.new(preload("res://assets/spit.ogg")))
			$Hitbox.set_collision_layer_value(8, false)
			$Hurtbox.set_collision_mask_value(7, true)
			
		elif shoot_type == 1:
			#shooter, collision_layer, velocity, num, delay, bulletparams:BulletParams = null
			get_tree().root.add_child(FreeAudio.new(preload("res://assets/untitled.ogg")))
			
			BulletManager.shoot_line(self, BulletManager.CollisionLayer.ENEMY,
			vec_to_crosshair*1500,
			1,
			0,
			bulletparams)
			extra_velocity += vec_to_crosshair * -1 * (2000 - 2000 * (traction_coeff - 1.0)) * knockback_factor

func shoot_loop():
	while Input.is_action_pressed("shoot"):
		await get_tree().create_timer(0.01).timeout 
		if Input.is_action_pressed("shoot"):
			shoot()

func set_start_room(room):
	self.curr_room = room

func set_curr_room(room):
	
	sprinting = room.cleared
	
	#print("Set room ", room.name)
	
	if curr_room == room:
		return
		
	#print(room.connected_rooms)
	#print("SET ROOM: ", room.name)
	prev_room = self.curr_room
	self.curr_room = room
	
	#if prev_room:
	#	print("SET ROOM: ", room.name, " PREV ROOM: ", prev_room.name)	


func _on_hurtbox_body_entered(body):
	
	print(body.get_parent())
	
	if body == self:
		return
	if body == $Hitbox:
		return
	
	var hitevent:HitEvent = HitEvent.new()
	
	hitevent.damage = damage_coeff * 50.0 * (extra_velocity.length() / 700.0)
	hitevent.knockback_dir = extra_velocity.normalized()
	hitevent.knockback_strength = extra_velocity.length() / 100.0
	
	extra_velocity *= -1
	
	$Hurtbox.set_collision_mask_value(7, false)
	print("you hit the enemy good job")
	if body.has_method("hit"):
		body.hit(hitevent)
		
	pass # Replace with function body.

func hit(hitevent):
	
	if invincible == true:
		return
		
	if in_menu:
		return
	
	start_invicible()
	
	var num = hearts_container.remove_heart()
	$Flash/ColorRect/AnimationPlayer.play("flash")
	get_tree().root.add_child(FreeAudio.new(preload("res://assets/player_hit.ogg")))
	if num <= 0:
		on_death.emit()

func _on_hurtbox_area_entered(area):
	print("POOP")
	pass # Replace with function body.

func start_invicible():
	$InvincibleTimer.start(0.8)
	$InvincibilityFlash.play("flash")
	invincible = true

func _on_invincible_timer_timeout():
	
	invincible = false
	$InvincibilityFlash.stop()
	
	pass # Replace with function body.

func upgrade():
	#get_tree().paused = true
	upgrades_since_mutation += 1
	$UpgradeMenu.upgrade_start()

func mutate():
	#get_tree().paused = true
	upgrades_since_mutation  = 0
	$MutationMenu.mutation_start()

func upgrade_picked(type):
	print("got here: ", type)
	match type:
		0:
			hearts_container.add_heart()
		1:
			damage_coeff += 0.05
		2:
			speed_coeff += 0.1
		3:
			charge_coeff += 0.1
		4:
			traction_coeff += 0.1
		5:
			bullet_scale_coeff += 0.2
		6:
			bullet_speed_coeff += 0.1
	update_values()
