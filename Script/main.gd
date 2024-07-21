extends Node2D

const PLAYER = preload("res://Scenes/player.tscn")
const CAMERA_2D = preload("res://Scenes/camera_2d.tscn")

@onready var dungeon = $Dungeon

var player = null
var camera_2d = null

var enemyTimer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Globals.main_scene = self
	
	
	dungeon.generate(gen_seed())
	
	player = PLAYER.instantiate()
	
	player.global_position = dungeon.get_start_room().get_middle_offset() + dungeon.get_start_room().global_position
	
	camera_2d = CAMERA_2D.instantiate()
	camera_2d.player = player
	
	add_child(player)
	add_child(camera_2d)

	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if event.is_action("zoom_in"):
		camera_2d.zoom += Vector2(0.1,0.1)
	if event.is_action("zoom_out"):
		camera_2d.zoom -= Vector2(0.1,0.1)

func gen_seed():
	var dung_seed = ""
	var time = Time.get_datetime_dict_from_system()
	for i in time.keys():
		dung_seed += str(time.get(i))
	return int(dung_seed)
