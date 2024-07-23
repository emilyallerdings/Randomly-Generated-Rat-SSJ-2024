extends CanvasLayer

const MINIMAP_HALLWAY = preload("res://assets/minimap_hallway.png")
const MINIMAP_UNKNOWN_ROOM = preload("res://assets/minimap_unknown_room.png")
const MINIMAP_CLEAR_ROOM = preload("res://assets/minimap_clear_room.png")
@onready var camera_2d = $SubViewportContainer/SubViewport/Camera2D
@onready var sub_viewport = $SubViewportContainer/SubViewport

var minimap_rooms = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.minimap = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func create_room(position):
	return

func spawn_connected_rooms(room):
	for x in room.connected_rooms:
		var connected_room = room.connected_rooms[x]
		
		if connected_room != null:
			if !minimap_rooms.has(connected_room):
				var new_sprite = Sprite2D.new()
				new_sprite.texture = MINIMAP_UNKNOWN_ROOM
				new_sprite.position = Vector2(44,36) * connected_room.vec_pos
				#camera_2d.position = new_sprite.position
				sub_viewport.add_child(new_sprite)
				minimap_rooms[connected_room] = new_sprite
				
			var new_hallway = Sprite2D.new()
			new_hallway.texture = MINIMAP_HALLWAY
			new_hallway.position = (minimap_rooms[connected_room].position - x * Vector2(21,17))
				
			if x == Vector2.RIGHT || x == Vector2.LEFT:
				new_hallway.rotate(deg_to_rad(90))
				
				print(x)
			sub_viewport.add_child(new_hallway)
	return

func player_entered_room(room):
	if !minimap_rooms.has(room):
		var new_sprite = Sprite2D.new()
		new_sprite.texture = MINIMAP_CLEAR_ROOM
		new_sprite.position = Vector2(44,36) * room.vec_pos
		#camera_2d.position = new_sprite.position
		sub_viewport.add_child(new_sprite)
		minimap_rooms[room] = new_sprite
		spawn_connected_rooms(room)
		
	if minimap_rooms.has(room) && room.opened == false:
		minimap_rooms[room].texture = MINIMAP_CLEAR_ROOM
		spawn_connected_rooms(room)
		
	
	for x in minimap_rooms.values():
		x.modulate = Color(1,1,1,1)
		
	camera_2d.position = minimap_rooms[room].position
	minimap_rooms[room].modulate = Color(2,2,2,1)
	
	return
