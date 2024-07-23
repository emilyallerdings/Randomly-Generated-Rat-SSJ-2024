extends CanvasLayer

var up_types = [-1,-1,-1]

var max_type = 6
@onready var upgrade_1 = $HBoxContainer/Upgrade1
@onready var upgrade_2 = $HBoxContainer/Upgrade2
@onready var upgrade_3 = $HBoxContainer/Upgrade3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func randomize_upgrades():
	up_types = [-1,-1,-1]
	for i in range(up_types.size()):
		var new_type = randi_range(0, max_type)
		while up_types.has(new_type):
			new_type = randi_range(0, max_type)
		up_types[i] = new_type
	
	upgrade_1.set_type(up_types[0])
	upgrade_2.set_type(up_types[1])
	upgrade_3.set_type(up_types[2])
	
func upgrade_start():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	randomize_upgrades()
	#get_tree().paused = true
	self.visible = true
	#get_parent().freeze_game(true)
	get_parent().in_menu = true
	
func upgrade_picked(type):
	
	if get_parent().in_menu == false:
		return
	
	#get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	self.visible = false
	#get_parent().freeze_game(false)
	get_parent().in_menu = false
	get_parent().upgrade_picked(type)


func _on_skip_button_pressed():
	if get_parent().in_menu == false:
		return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	self.visible = false
	get_parent().in_menu = false

	pass # Replace with function body.
