extends Node

var main_scene

var minimap = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_child_to_main(child):
	main_scene.add_child(child)
