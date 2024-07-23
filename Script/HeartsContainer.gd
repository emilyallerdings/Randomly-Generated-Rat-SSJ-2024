extends HBoxContainer

const HEART_RECT = preload("res://Scenes/HeartRect.tscn")

var heart_num = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_heart():
	heart_num += 1
	add_child(HEART_RECT.instantiate())

func remove_heart():
	heart_num -= 1
	if get_child_count() == 0:
		return 0
	var heart = get_children().pop_front()
	heart.queue_free()
	return heart_num
