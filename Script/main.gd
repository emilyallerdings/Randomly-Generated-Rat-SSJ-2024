extends Node2D

const PLAYER = preload("res://Scenes/player.tscn")
const CAMERA_2D = preload("res://Scenes/camera_2d.tscn")
const BULLET = preload("res://Scenes/bullet.tscn")
const RESTART_MENU = preload("res://Scenes/RestartMenu.tscn")

@onready var dungeon = $Dungeon


var red_mod = 0.0
var player = null
var camera_2d = null

var enemyTimer = 0
const DUNGEON = preload("res://Scenes/dungeon.tscn")
const MINIMAP = preload("res://Scenes/minimap.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	BulletManager.main = self
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Globals.main_scene = self
	Globals.difficulty = 1
	Globals.floor_num = 1
	dungeon.generate(gen_seed())
	
	player = PLAYER.instantiate()
	
	player.global_position = dungeon.get_start_room().get_middle_offset() + dungeon.get_start_room().global_position
	player.set_start_room(dungeon.get_start_room())
	
	camera_2d = CAMERA_2D.instantiate()
	camera_2d.player = player
	
	add_child(player)
	add_child(camera_2d)

	player.on_death.connect(player_died)
	pass # Replace with function body.

func leave_dungeon():
	Globals.floor_num += 1
	Globals.difficulty -= 0.25
	red_mod += 0.05
	red_mod = clamp(red_mod, 0.0, 0.2)
	player.global_position = dungeon.get_start_room().get_middle_offset() + dungeon.get_start_room().global_position
	get_tree().call_group("bullet", "queue_free")
	$Minimap.queue_free()
	dungeon.queue_free()
	
	await get_tree().create_timer(1.5).timeout

	dungeon = DUNGEON.instantiate()
	add_child(MINIMAP.instantiate())
	add_child(dungeon)
	dungeon.modulate = Color(1.0 - red_mod,1.0 - red_mod,1.0 - red_mod)
	dungeon.generate(gen_seed())
	return

func player_died():
	get_tree().call_deferred("change_scene_to_packed", (RESTART_MENU))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	#if event.is_action("zoom_in"):
		#camera_2d.zoom += Vector2(0.1,0.1)
	#if event.is_action("zoom_out"):
		#camera_2d.zoom -= Vector2(0.1,0.1)
	#if event.is_action_pressed("test"):
		#print("pressed")
		#leave_dungeon()
	return

func gen_seed():
	var dung_seed = ""
	var time = Time.get_datetime_dict_from_system()
	for i in time.keys():
		dung_seed += str(time.get(i))
	return int(dung_seed)

func create_bullet(shooter, collision_layer, velocity, offset, position, bulletparams:BulletParams = null):
	
	
	var nbullet:Bullet = BULLET.instantiate()
	nbullet.shooter = shooter
	nbullet.set_collision_mask_value(collision_layer, true)
	nbullet.position = position + velocity.normalized()*offset
	nbullet.velocity = velocity
	
	if bulletparams:
		nbullet.velocity = nbullet.velocity.normalized() * bulletparams.speed
		nbullet.scale = nbullet.scale * bulletparams.size
		nbullet.damage = bulletparams.damage
		nbullet.slowdown = bulletparams.slowdown
		nbullet.sway = bulletparams.sway
		#nbullet.spread = bulletparams.spread
		var angle = randi_range(-bulletparams.spread, bulletparams.spread)
		nbullet.velocity.rotated(deg_to_rad(angle))
		nbullet.death_effect = bulletparams.death_effect
		nbullet.color = bulletparams.color

		
	add_child(nbullet)
	
	return nbullet

func shoot_line(shooter, collision_layer, velocity, num, delay, bulletparams:BulletParams = null):
	for i in range(num):
		
		if !is_instance_valid(shooter):
			return
			
		if shooter.has_method("is_broken") && shooter.is_broken() == true:
			return
		
		if is_instance_valid(shooter):
			if shooter.has_method("on_shoot"):
				shooter.on_shoot()
			var nbullet = create_bullet(shooter, collision_layer, velocity, 25, shooter.global_position, bulletparams)
			
			
			await get_tree().create_timer(delay).timeout

func shotgun(shooter, collision_layer, velocity, num, spread, speed_vary, slow_down, bulletparams:BulletParams = null):
	if !is_instance_valid(shooter):
		return
	
	if shooter.has_method("on_shoot"):
		shooter.on_shoot()
	for i in range(num):
		var rand = randi_range(-spread,spread)
		var rand_speed = randi_range(2 * speed_vary, speed_vary)
		var speed_diff:float = 1.0 - rand_speed/velocity.length()
		
		var nbullet = create_bullet(shooter, collision_layer, velocity.rotated(deg_to_rad(rand)) * speed_diff, 25, shooter.global_position, bulletparams)

func even_shotgun(shooter, collision_layer, velocity, num, spread, speed_vary, slow_down, bulletparams:BulletParams = null):
	if !is_instance_valid(shooter):
		return
			
	if shooter.has_method("on_shoot"):
		shooter.on_shoot()
		
	var angle:float = 0-float(spread)/2.0
	
	for i in range(num):
		#var rand = randi_range(-spread,spread)
		var rand_speed = randi_range(2 * speed_vary, speed_vary)
		var speed_diff:float = 1.0 - rand_speed/velocity.length()
		
		
		
		var nbullet = create_bullet(shooter, collision_layer, velocity.rotated(deg_to_rad(angle)) * speed_diff, 25, shooter.global_position, bulletparams)
		angle += (spread / float(num-1))

func upgrade():
	
	$UpgradeMenu.upgrade_start()

func freeze_game(val):
	$Dungeon.set_process(val)
	$Player.set_process(val)
