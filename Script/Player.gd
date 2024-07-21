extends CharacterBody2D
class_name Player

@onready var crosshair = $Crosshair
@onready var energy_bar = $CanvasLayer/EnergyBar
#@onready var camera_2d = $Camera2D
#@onready var anim_sprite = $AnimSprite

var vec_to_crosshair

const BULLET = preload("res://Scenes/bullet.tscn")
const SPEED = 300.0
const MAX_ENERGY:float = 100

var energy:float = MAX_ENERGY
var extra_velocity:Vector2 = Vector2(0,0)

var current_room = null

func _ready():
	#anim_sprite.play("default")
	return

func _physics_process(delta):

	var direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = Vector2.ZERO
	
	#if extra_velocity.length() < 100:
	#	velocity = direction.normalized() * SPEED
	
	#velocity = direction.normalized() * SPEED
	
	direction = direction.normalized() * SPEED
	
	var vel_dif = direction.dot(extra_velocity.normalized())
	if vel_dif < 0 && extra_velocity.length() > 100:
		direction -= vel_dif*extra_velocity.normalized()
		direction * 0.25
	
	velocity += direction
	
	velocity += extra_velocity
	extra_velocity = extra_velocity.lerp(Vector2.ZERO, delta * 10)
	
	
	
	move_and_slide()
	#self.position = position.round()

func _process(delta):
	crosshair.position = get_local_mouse_position()
	vec_to_crosshair = (crosshair.global_position - self.global_position).normalized()
	
	energy = clamp(energy+10*delta, 0, 100)
	energy_bar.scale.x = energy/MAX_ENERGY
	
	var mouse_pos = get_global_mouse_position()
	#camera_2d.offset.x = round((mouse_pos.x - global_position.x) / (1920.0 / 2.0) * 150)
	#camera_2d.offset.y = round((mouse_pos.y - global_position.y) / (1080.0 / 2.0) * 150)
	
	
	
	if mouse_pos < self.global_position:
		$Rat.scale.x = 1
		$Rat.look_at(mouse_pos)
		$Rat.rotation += deg_to_rad(180)
	else:
		$Rat.scale.x = -1
		$Rat.look_at(mouse_pos)
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
		energy -= 100
		$AudioStreamPlayer.play()
		#BulletManager.create_bullet(self, BulletManager.CollisionLayer.ENEMY, vec_to_crosshair*1500, 25, self.global_position)
		BulletManager.shotgun(self, BulletManager.CollisionLayer.ENEMY, vec_to_crosshair*1500, 15, 35, 500, 0)
		#DebugDraw2D.line(self.position, self.position + (vec_to_crosshair * self.global_position.distance_to(crosshair.global_position)), Color.RED, 3, 0.5)
		#extra_velocity += vec_to_crosshair * -1 * 5000
