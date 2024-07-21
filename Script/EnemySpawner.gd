extends Node2D

const ENEMY = preload("res://Scenes/Enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	var new_enemy = ENEMY.instantiate()
	new_enemy.global_position = self.global_position
	new_enemy.modulate = Color.from_hsv(randf(), 1.0 , 1.0)
	get_parent().add_child(new_enemy)
	pass # Replace with function body.
