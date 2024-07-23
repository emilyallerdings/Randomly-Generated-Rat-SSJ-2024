extends Node2D

const DOOR_SIDE = preload("res://assets/door_side.png")
const DOOR_FRONT = preload("res://assets/door_front.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func open():
	$AnimationPlayer.play("open")
	
func close():
	$AnimationPlayer.play_backwards("open")

func set_side(val):
	if val:
		$Sprite2D.texture = DOOR_SIDE
	else:
		$Sprite2D.texture = DOOR_FRONT
