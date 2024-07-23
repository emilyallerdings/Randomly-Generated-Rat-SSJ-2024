extends ColorRect

@export var id = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Button.pressed.connect(button_pressed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func button_pressed():
	get_parent().get_parent().pressed(id)

func set_title(text):
	$Title.text = text
	
func set_desc(text):
	$Desc.text = text
