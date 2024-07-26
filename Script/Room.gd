#@tool
extends Node2D
class_name Room

signal on_entered

const TILE_SIZE = 64

@onready var black = $Black

const LOCK_DOOR = preload("res://Scenes/LockDoor.tscn")
const GRADIENT = preload("res://Scenes/gradient.tscn")
const UPGRADE = preload("res://Scenes/Upgrade.tscn")

const black_texture = preload("res://assets/black.png")

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

@onready var entities = $Entities

var is_final_room = false

var turrets = []
var door_arr = []

var color_rect
var vec_pos

var cleared = false

var nav_poly:NavigationPolygon

var opened = false
const ROOM = preload("res://Scenes/room.tscn")
const SCIENTIST = preload("res://Scenes/scientist.tscn")

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
	color_rect.texture = black_texture
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

	self.cleared = false
	
	if starting_room == true:
		self.cleared = true
		enter_room()
		
	
	#shape.disabled = false

func room_cleared():
	if is_final_room:
		$ExitDoor.visible = true
		$ExitDoor.play("open")
		Globals.difficulty -= 2.0
	
	if cleared:
		return
	
	self.cleared = true
	get_tree().get_first_node_in_group("player").sprinting = true
	Globals.difficulty += 0.25
	for door in door_arr:
		door.open()
	
	var n_upgrade = UPGRADE.instantiate()
	n_upgrade.position = get_middle()*TILE_SIZE
	add_child(n_upgrade)
	get_tree().call_group("bullet", "queue_free")
	
	#var new_upgrade =

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

func fill_room():
	var num_enemies = randi_range(1 + floor(Globals.difficulty * 0.30), 1 + floor(Globals.difficulty * 0.40))
	for num in range(num_enemies):
		
		var n_enemy = SCIENTIST.instantiate()
		var pos = Vector2(randi_range(TILE_SIZE*2, TILE_SIZE*(width_in_tiles-2)),
		 randi_range(TILE_SIZE*2, TILE_SIZE*(height_in_tiles-2)))
		
		n_enemy.position = pos
		entities.add_child(n_enemy)
		
		
func enter_room():
	if is_final_room:
		self.modulate = Color(0.8,0.2,0.2)
		Globals.difficulty += 2.0
		$ExitDoor.position = get_middle_offset() + Vector2(32,32)
		$ExitDoor.visible = true
		
	if starting_room == false:
		spawn_doors()
		fill_room()
	opened = true
	$Entities.process_mode = Node.PROCESS_MODE_ALWAYS
	#print("ROOM:", name)
	$AnimationPlayer.play("fade_out")

func spawn_doors():
	var middle = get_middle()
	
	for door_dir in connected_rooms:
		if connected_rooms.get(door_dir) != null:
			var n_door = LOCK_DOOR.instantiate()
			var door_pos = get_door_pos(middle, door_dir) * TILE_SIZE
			n_door.position = door_pos
			
			if door_dir.y == 0:
				n_door.position -= door_dir * 36
				n_door.set_side(true)
				n_door.scale.y = 1.5
				n_door.position.y -= 32
			
			if door_dir.y == -1:
				n_door.z_index = 8
				n_door.position -= door_dir * 12
			else:
				n_door.z_index = 10
				
			n_door.position -= door_dir * 16
			add_child(n_door)
			
			door_arr.append(n_door)
			
			n_door.close()
			if n_door.global_position.distance_to(get_tree().get_first_node_in_group("player").global_position) <= 200:
				lerp_player_into_room(door_dir, get_tree().get_first_node_in_group("player").global_position)

func lerp_player_into_room(dir, pos):
	var player = get_tree().get_first_node_in_group("player")
	while pos.distance_to(player.global_position) <= 200:
		player.global_position = lerp(player.global_position, pos + 240*-1*dir, 0.1)
		player.global_position = snapped(player.global_position, Vector2(0.5,0.5))
		await get_tree().process_frame 

func create_room(width, height):
	
				
	for x in range(width):
		for y in range(height):
			
			$TileMap.set_cell(0, Vector2(x,y), 10, Vector2(0,0))
			
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

func get_middle():
	return Vector2(floor(width_in_tiles/2), floor(height_in_tiles/2))

func get_door_pos(middle, direction):
	var door_pos = Vector2(
		middle.x + direction.x * width_in_tiles/2,
		middle.y + direction.y * height_in_tiles/2)
	return door_pos

func connect_room2(room, direction):
	
	if self.connected_rooms[direction] == room:
		return
	
	var middle = get_middle()
	
	self.connected_rooms[direction] = room

	var door_pos = get_door_pos(middle, direction)
	
	
	
	match direction:
		Vector2.UP:
			var ngrad = GRADIENT.instantiate()
			ngrad.position = middle*64 - Vector2(0, (floor(height_in_tiles/2) + 1)*64) + Vector2(32,32)
			ngrad.rotate(deg_to_rad(90))
			black.add_child(ngrad)
			ngrad.scale.x = 1.5

			$TileMap.set_cell(0, door_pos, 10, Vector2(0,0))
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
			$TileMap.set_cell(0, door_pos, 10, Vector2(0,0))
			
		Vector2.DOWN:
			var ngrad = GRADIENT.instantiate()
			ngrad.position = middle*64 + Vector2(0, (floor(height_in_tiles/2) + 1)*64) + Vector2(32,32)
			ngrad.rotate(deg_to_rad(-90))
			black.add_child(ngrad)
			ngrad.scale.x = 1.5
			$TileMap.set_cell(0, door_pos, 10, Vector2(0,0))
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
			$TileMap.set_cell(0, door_pos, 10, Vector2(0,0))
	
func get_dir_to_room(room):
	
	if room == null:
		#print("WHAT THE FUCK")
		return Vector2.ZERO
	
	for rooms in connected_rooms.values():
		if rooms == room:
			#print("YAY")
			return connected_rooms.find_key(rooms)
	return Vector2.ZERO

func _on_enter_room_body_entered(body):

	#print(body.name + " " + str(body.global_position) + " " + str(name) + ": " + str(shape.global_position) + ", " + str(shape.shape.size))
	#print(opened)
	
	if body.is_in_group("player"):
		body.set_curr_room(self)
		on_entered.emit()
	
	if body.is_in_group("player") && opened == false:
		enter_room()
		#print(self.name)
		#shape.disabled = true
		
	pass # Replace with function body.


func player_exit(body):
	print("leave")
	if body is Player:
		Globals.main_scene.leave_dungeon()
	pass # Replace with function body.


func _on_exit_door_animation_finished():
	print("open")
	$ExitDoor/Area2D.set_collision_mask_value(8, true)
	$ExitDoor/Area2D.set_collision_mask_value(1, true)
	pass # Replace with function body.
