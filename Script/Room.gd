@tool
extends Node2D
class_name Room

signal on_entered

const TILE_SIZE = 64

@onready var black = $Black


const GRADIENT = preload("res://Scenes/gradient.tscn")

var connected_rooms = {
	Vector2.UP: null,
	Vector2.RIGHT: null,
	Vector2.DOWN: null,
	Vector2.LEFT: null
}

@export var starting_room:bool = false

@export var width_in_tiles:int = 15
@export var height_in_tiles:int = 9
@export var starting_location:Vector2

@onready var shape = $EnterRoom/Shape

@onready var navigation_region = $NavigationRegion2D

var color_rect
var vec_pos

var nav_poly:NavigationPolygon

var opened = false
const ROOM = preload("res://Scenes/room.tscn")

static func create(width:int = 15,height:int = 9, vec_pos:Vector2 = Vector2.ZERO):
	var new_room = ROOM.instantiate()
	new_room.width_in_tiles = width
	new_room.height_in_tiles = height
	
	new_room.vec_pos = vec_pos
	
	return new_room

# Called when the node enters the scene tree for the first time.
func _ready():
	create_room(width_in_tiles, height_in_tiles)
	
	color_rect = Sprite2D.new()
	color_rect.texture = preload("res://assets/black.png")
	black.add_child(color_rect)
	
	color_rect.visible = true
	color_rect.z_index = 7
	
	color_rect.scale.x = width_in_tiles
	color_rect.scale.y = height_in_tiles
	
	color_rect.position.x = TILE_SIZE*width_in_tiles/2
	color_rect.position.y = TILE_SIZE*height_in_tiles/2
	
	shape.shape.size.x = TILE_SIZE*width_in_tiles
	shape.shape.size.y = TILE_SIZE*height_in_tiles
	shape.position.x = TILE_SIZE*width_in_tiles/2
	shape.position.y = TILE_SIZE*height_in_tiles/2
	

	var vec_arr:PackedVector2Array = PackedVector2Array()

	vec_arr.append(Vector2(TILE_SIZE,TILE_SIZE))
	vec_arr.append(Vector2(TILE_SIZE*(width_in_tiles-1), TILE_SIZE*1))
	vec_arr.append(Vector2(TILE_SIZE*(width_in_tiles-1), TILE_SIZE*(height_in_tiles-1)))
	vec_arr.append(Vector2(TILE_SIZE*1, TILE_SIZE*(height_in_tiles-1)))

	var new_navigation_mesh = NavigationPolygon.new()
	var bounding_outline = vec_arr
	new_navigation_mesh.add_outline(bounding_outline)
	NavigationServer2D.bake_from_source_geometry_data(new_navigation_mesh, NavigationMeshSourceGeometryData2D.new());
	$NavigationRegion2D.navigation_polygon = new_navigation_mesh


	
	if starting_room == true:
		enter_room()
		
	
	shape.disabled = false

func setup_navmesh():
	print (nav_poly.get_navigation_mesh().get_polygon(0))
	
	#navigation_region.set_navigation_polygon(nav_poly)
	#navigation_region.bake_navigation_polygon(true)
	#print ("hi: ", navigation_region.get_navigation_polygon())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func get_middle_offset():
	var middle = Vector2(floor(width_in_tiles/2) * TILE_SIZE, floor(height_in_tiles/2) * TILE_SIZE)
	return middle
	
func enter_room():

	opened = true
	$Entities.process_mode = Node.PROCESS_MODE_ALWAYS
	#print("ROOM:", name)
	$AnimationPlayer.play("fade_out")

func create_room(width, height):
	for x in range(width):
		for y in range(height):
			
			$TileMap.set_cell(0, Vector2(x,y), 0, Vector2(1,1))
			
			if y == 0:
				$TileMap.set_cell(0, Vector2(x,y), 3, Vector2.ZERO)
			if y == height-1:
				$TileMap.set_cell(0, Vector2(x,y), 7, Vector2.ZERO, 2)
				
			if x == 0:
				$TileMap.set_cell(0, Vector2(x,y), 7, Vector2.ZERO, 1)
				if y == height-1:
					$TileMap.set_cell(0, Vector2(x,y), 9, Vector2.ZERO, 0)
			if x == width-1:
				$TileMap.set_cell(0, Vector2(x,y), 7, Vector2.ZERO, 0)	
				if y == height-1:
					$TileMap.set_cell(0, Vector2(x,y), 9, Vector2.ZERO, 1)
	return

func connect_room(room, direction):
	
	if self.connected_rooms[direction] == room:
		return
	
	var middle = Vector2(floor(width_in_tiles/2), floor(height_in_tiles/2))
	
	self.connected_rooms[direction] = room

	var door_pos = Vector2(
		middle.x + direction.x * width_in_tiles/2,
		middle.y + direction.y * height_in_tiles/2)
	
	match direction:
		Vector2.UP:
			var ngrad = GRADIENT.instantiate()
			ngrad.position = middle*64 - Vector2(0, (floor(height_in_tiles/2) + 1)*64) + Vector2(32,32)
			ngrad.rotate(deg_to_rad(90))
			black.add_child(ngrad)

			$TileMap.set_cell(0, door_pos, 0, Vector2(1,1))
			$TileMap.set_cell(0, door_pos - Vector2(-1,1), 8, Vector2.ZERO, 2)
			$TileMap.set_cell(0, door_pos - Vector2(1,1), 8, Vector2.ZERO, 1)
			
		Vector2.RIGHT:
			var ngrad = GRADIENT.instantiate()
			ngrad.position = middle*64 + Vector2((floor(width_in_tiles/2) + 1)*64, 0) + Vector2(32,32)
			ngrad.rotate(deg_to_rad(180))
			ngrad.scale.y = 3
			black.add_child(ngrad)
			
			$TileMap.set_cell(0, door_pos - Vector2(0,1), 3, Vector2.ZERO, 0)
			$TileMap.set_cell(0, door_pos + Vector2(0,1), 8, Vector2.ZERO, 2)
			$TileMap.set_cell(0, door_pos, 0, Vector2(1,1), 0)
			
		Vector2.DOWN:
			var ngrad = GRADIENT.instantiate()
			ngrad.position = middle*64 + Vector2(0, (floor(height_in_tiles/2) + 1)*64) + Vector2(32,32)
			ngrad.rotate(deg_to_rad(-90))
			black.add_child(ngrad)
			
			$TileMap.set_cell(0, door_pos, 0, Vector2(1,1))
			$TileMap.set_cell(0, door_pos + Vector2(1,0), 8, Vector2.ZERO, 2)
			$TileMap.set_cell(0, door_pos + Vector2(-1,0), 8, Vector2.ZERO, 1)
			
		Vector2.LEFT:
			
			var ngrad = GRADIENT.instantiate()
			ngrad.position = middle*64 - Vector2((floor(width_in_tiles/2) + 1)*64, 0) + Vector2(32,32)
			ngrad.rotate(deg_to_rad(0))
			black.add_child(ngrad)
			ngrad.scale.y = 3
			
			$TileMap.set_cell(0, door_pos - Vector2(0,1), 3, Vector2.ZERO, 0)
			$TileMap.set_cell(0, door_pos + Vector2(0,1), 8, Vector2.ZERO, 1)
			$TileMap.set_cell(0, door_pos, 0, Vector2(1,1), 0)
	


func _on_enter_room_body_entered(body):

	#print(body.name + " " + str(body.global_position) + " " + str(name) + ": " + str(shape.global_position) + ", " + str(shape.shape.size))
	#print(opened)
	
	if body.is_in_group("player"):
		body.current_room = self
		on_entered.emit()
	
	if body.is_in_group("player") && opened == false:
		enter_room()
		#print(self.name)
		#shape.disabled = true
		
	pass # Replace with function body.
