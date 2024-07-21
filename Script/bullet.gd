extends Node2D
class_name Bullet

const BULLET_EFFECT = preload("res://Scenes/BulletEffect.tscn")

var velocity:Vector2 = Vector2(0,0)
var shooter = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	self.position += velocity * delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(position)
	pass

func _on_body_entered(body):
	if body.has_method("hit"):
		
		var hit_event = HitEvent.new()
		hit_event.knockback_dir = self.velocity.normalized()
		hit_event.knockback_strength = 50
		hit_event.shooter = self.shooter
		hit_event.damage = 10
		
		body.hit(hit_event)
		
	
	
	_on_timer_timeout()
	pass # Replace with function body.


func _on_area_entered(area):
	
	pass # Replace with function body.


func _on_timer_timeout():
	var neff = BULLET_EFFECT.instantiate()
	neff.global_position = self.global_position
	get_parent().add_child(neff)
	
	var dir = velocity.normalized() * -1
	
	neff.start(dir)
	self.hide()
	queue_free()
	pass # Replace with function body.
