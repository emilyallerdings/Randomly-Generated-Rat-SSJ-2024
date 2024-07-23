extends CanvasLayer


var player:Player

var up_types = [0,0,0]

var category = 0
var from_type = 0
var to_type = 0

var max_type = 0
@onready var from = $HBoxContainer/From
@onready var to = $HBoxContainer/To


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func randomize_mutation():
	category = randi_range(0, 2)
	match category:
		0:
			from_type = player.shoot_type
			max_type = 3
			$Type.text = "Weapon"

		1:
			from_type = player.stomach_type
			max_type = 2
			$Type.text = "Stomach"
			
		2:
			from_type = player.feet_type
			max_type = 3
			$Type.text = "Feet"
			

	var new_type = randi_range(1, max_type)
	while from_type == new_type:
		new_type = randi_range(1, max_type)
	to_type = new_type
	
	from.set_title(Globals.titles[category][from_type-1])
	to.set_title(Globals.titles[category][to_type-1])
	
	var from_desc:String = Globals.descriptions[category][from_type-1]
	var to_desc:String  = Globals.descriptions[category][to_type-1]
	
	from.set_desc(from_desc)
	to.set_desc(to_desc)
	
	#$HBoxContainer/From.
	
func mutation_start():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	randomize_mutation()
	#get_tree().paused = true
	self.visible = true
	#get_parent().freeze_game(true)
	get_parent().in_menu = true

func pressed(id):
	match id:
		0:
			mutation_picked(from_type)
		1:
			mutation_picked(to_type)
			
func mutation_picked(type):
	
	if get_parent().in_menu == false:
		return
	
	#get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	self.visible = false
	#get_parent().freeze_game(false)
	get_parent().in_menu = false
	match category:
		0:
			player.update_weapon(type)
		1:
			player.update_stomach(type)
		2:
			player.update_feet(type)
