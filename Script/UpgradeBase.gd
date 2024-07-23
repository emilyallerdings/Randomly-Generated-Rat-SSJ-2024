extends ColorRect

@onready var label = $Label
@onready var button = $Button

var type = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	button.pressed.connect(button_pressed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_type(type):
	$Label.text = "Type " + str(type)
	self.type = type
	match type:
		0:
			$Label.text = "Increase Health"
		1:
			$Label.text = "Increase Damage"
		2:
			$Label.text = "Increase Rat Speed"
		3:
			$Label.text = "Increase Charge"
		4:
			$Label.text = "Increase Traction"
		5:
			$Label.text = "Increase Bullet Size"
		6:
			$Label.text = "Increase Bullet Speed"
	return

func button_pressed():
	get_parent().get_parent().upgrade_picked(type)
