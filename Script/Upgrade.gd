extends Area2D

var player
var attract = false
var speed = 0.1

var type = 0

const UPGRADE_GREEN = preload("res://assets/upgrade_green.png")
const UPGRADE_PURPLE = preload("res://assets/upgrade_purple.png")

var spawn_vel = -400

# Called when the node enters the scene tree for the first time.
func _ready():
	
				
	player = get_tree().get_first_node_in_group("player")
	
	var rand = randi_range(player.upgrades_since_mutation, 10)
	if rand <= 8:
		type = 0
	else:
		type = 1
	
	match type:
		0:
			$Sprite2D.texture = UPGRADE_GREEN
			self.modulate = Color(1.1,1.1,1.1)
		1:
			$Sprite2D.texture = UPGRADE_PURPLE
			self.modulate = Color(2.1,2.1,2.1)
	
	await get_tree().create_timer(0.3).timeout
	set_collision_mask_value(1, true)
	attract = true
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if attract:
		if player:
			speed += clamp(speed * (10 * delta), 0, 1000)
			self.global_position = self.global_position.lerp(player.global_position, speed*delta)
	else:
		self.position.y += spawn_vel*delta
		spawn_vel += (delta * 1200)
	pass


func _on_body_entered(body):
	if body == player:
		match type:
			0:
				player.upgrade()
			1:
				player.mutate()
		queue_free()
	pass # Replace with function body.
