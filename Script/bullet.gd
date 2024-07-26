extends Node2D
class_name Bullet

const BULLET_EFFECT = preload("res://Scenes/BulletEffect.tscn")

var velocity:Vector2 = Vector2(0,0)
var shooter = null
var damage = 10

var slowdown = 0
var spread = 0
var sway = 0
var color
var death_effect:DeathEffect = null
var speed = 1
var test_color = Color(0,1,3,1)
var used = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if color:
		$Glow.modulate = color

		$Icon.modulate = color
	else:
		color = $Icon.modulate
		$Glow.modulate = color
	#$Icon.self_modulate = color
	#self_modulate = 
	#self_modulate = $Icon.modulate * 3.0
	#self_modulate.a = 1.0
	pass # Replace with function body.

func _physics_process(delta):
	self.position += velocity * delta
	velocity = velocity.lerp(Vector2.ZERO, delta*slowdown)
	self.position.y += sway*delta*sin(Time.get_ticks_msec()/100.0)
	
	if self.velocity.length() <= 20:
		await get_tree().create_timer(randf_range(0.01,0.03)).timeout
		try_death_effect()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(position)
	pass

func try_death_effect():
	if death_effect:
		death_effect.on_trigger(self)
		death_effect = null
		used = true
		self.hide()
		queue_free()

func _on_body_entered(body):
	#print("hit ", body)
	
	if used:
		return
	
	if body.has_method("hit"):
		used = true
		var hit_event = HitEvent.new()
		hit_event.knockback_dir = self.velocity.normalized()
		hit_event.knockback_strength = 50
		hit_event.shooter = self.shooter
		hit_event.damage = damage
		
		body.hit(hit_event)
		
	
	await get_tree().create_timer(randf_range(0.01,0.02)).timeout
	_on_timer_timeout()
	pass # Replace with function body.


func _on_area_entered(area):
	
	pass # Replace with function body.


func _on_timer_timeout():
	var neff = BULLET_EFFECT.instantiate()
	neff.global_position = self.global_position
	get_parent().add_child(neff)
	try_death_effect()
	var dir = velocity.normalized() * -1
	
	neff.start(dir, color)
	self.hide()
	queue_free()
	pass # Replace with function body.
