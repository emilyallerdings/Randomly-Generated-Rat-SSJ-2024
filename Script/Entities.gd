extends Node2D
class_name Entities

var total_enemies = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func get_room():
	return get_parent()

func enemy_added(enemy):
	total_enemies += 1
	print(total_enemies)

func enemy_removed(pos):
	total_enemies -= 1
	print(total_enemies)
	handle_enemy_killed()

func handle_enemy_killed():
	if total_enemies <= 0:
		get_parent().room_cleared()
