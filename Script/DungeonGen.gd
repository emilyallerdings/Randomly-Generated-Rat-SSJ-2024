extends Node

const ROOM = preload("res://Scenes/room.tscn")

var roomVectors = {
	0: Vector2.UP,
	1: Vector2.RIGHT,
	2: Vector2.DOWN,
	3: Vector2.LEFT
}

var dungeon = {}

var min_rooms = 8
var max_rooms = 14
var gen_chance = 40


func generate(seed):
	print(seed)
	seed(seed)
	var dungeon = {}
	var size = randi_range(min_rooms, max_rooms)
	
	dungeon[Vector2.ZERO] = generate_room(null, null)
	
	size -= 1
	
	while size > 0:
		for i in dungeon.keys():
			if randi_range(0,100) < gen_chance:
				#print(i)
				var direction = roomVectors.get(randi_range(0,3))
				var new_room_pos = i + direction
				#print (new_room_pos)
				if !dungeon.has(new_room_pos):
					dungeon[new_room_pos] = generate_room(dungeon.get(i), direction)
					dungeon[new_room_pos].name = str(new_room_pos)
					dungeon[new_room_pos].vec_pos = new_room_pos
					size -= 1
				connect_rooms(dungeon.get(i), dungeon.get(new_room_pos), direction)
	
	self.dungeon = dungeon

func clear_dungeon():
	if dungeon == null:
		return
		
	for i in dungeon.keys():
		i.queue_free()

func connect_rooms(room1, room2, direction):
	room1.connect_room(room2, direction)
	room2.connect_room(room1, -direction)
					
func generate_room(prev_room, direction):
	
	
	var new_room:Room = Room.create(21,13)
	#new_room.global_position = Vector2(0,0)
	
	new_room.on_entered.connect(on_room_entered.bind(new_room))
	
	if prev_room != null:
		if direction == Vector2.RIGHT || direction == Vector2.DOWN:
			new_room.global_position = prev_room.position + (direction *
			 Vector2(prev_room.width_in_tiles * 64, prev_room.height_in_tiles * 64))
		else:
			new_room.global_position = prev_room.position + (direction *
			 Vector2(new_room.width_in_tiles * 64, new_room.height_in_tiles * 64))
	
	if prev_room == null:
		new_room.starting_room = true
	
	add_child(new_room)
	
	
	return new_room

func get_start_room():
	return dungeon[Vector2.ZERO]

func is_even(x):
	if x % 2 == 0:
		return true
	return false

func on_room_entered(room):
	Globals.minimap.player_entered_room(room)

func _process(delta):
	#for room in dungeon.values():
	#	if room.opened == true:
	#		print(room)
	return
