extends Node

const ROOM = preload("res://Scenes/room.tscn")

const TILE_SIZE = 64

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

var furthest_room = Vector2.ZERO

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
	#print(get_furthest_room(dungeon[Vector2.ZERO]))
	#print("Furthest_Room, ", furthest_room)
	
	#var new_final = true
	#for connection in dungeon.get(furthest_room).connections.values():
		#if connection != null
	find_far_room()
	
	
func clear_dungeon():
	if dungeon == null:
		return
		
	for i in dungeon.keys():
		i.queue_free()

func connect_rooms(room1, room2, direction):
	room1.connect_room2(room2, direction)
	room2.connect_room2(room1, -direction)

func get_furthest_room(from_room):
	var rooms_visited = []
	return recur_furthest_room(from_room, 0, Vector2.ZERO, 0, rooms_visited)
		
func recur_furthest_room(cur_room, num, from_dir, max, rooms_visited):
	rooms_visited.append(cur_room)
	var cur_val = num
	for connection in cur_room.connected_rooms.keys():
		#print(cur_room, " : ", connection, " : ", from_dir)
		if connection != -from_dir && cur_room.connected_rooms.get(connection) != null && !rooms_visited.has(cur_room.connected_rooms.get(connection)):
			cur_val = recur_furthest_room(cur_room.connected_rooms.get(connection), num + 1, connection, cur_val, rooms_visited)
	rooms_visited.erase(cur_room)
	if cur_val > max:
		furthest_room = cur_room
	return max(max,cur_val)
	

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

func find_far_room():
	var test_node = Node2D.new()
	
	var nav_agent:NavigationAgent2D = NavigationAgent2D.new()
	test_node.position = dungeon.get(Vector2.ZERO).get_middle()
	add_child(test_node)
	nav_agent.set_navigation_layer_value(1, false)
	nav_agent.set_navigation_layer_value(2, true)
	test_node.add_child(nav_agent)
	
	var new_navigation_mesh = NavigationPolygon.new()
	new_navigation_mesh.add_outline([Vector2(-10000, - 10000), Vector2(10000, -10000), Vector2(10000, 10000), Vector2(-10000, 10000)])
	
	var data = NavigationMeshSourceGeometryData2D.new()
	
	NavigationServer2D.parse_source_geometry_data(new_navigation_mesh, data, self)
	NavigationServer2D.bake_from_source_geometry_data(new_navigation_mesh, data);
	$NavigationRegion2D.navigation_polygon = new_navigation_mesh
	
	#await $NavigationRegion2D.bake_finished
	print("bake done")
	var furthest_room = Vector2.ZERO
	var max_dist = 0
	for rooms in dungeon:
		
		test_node.position = dungeon.get(rooms).get_middle()*TILE_SIZE + dungeon.get(rooms).global_position
		
		nav_agent.target_position = dungeon.get(Vector2.ZERO).get_middle()*TILE_SIZE
		#print(test_node.position, " : ", nav_agent.target_position)
		await get_tree().create_timer(0.1).timeout
		var dist = 0
		var next_pos = (nav_agent.get_next_path_position())
		var path = nav_agent.get_current_navigation_path()
		for index in range(0, path.size()-1):
			dist += path[index].distance_to(path[index + 1])
		
		
		#print(sum_nav_path(nav_agent.get_current_navigation_path(), nav_agent, test_node.global_position))
		
		if dist > max_dist:
			max_dist = dist
			furthest_room = rooms
	print(furthest_room)
	dungeon.get(furthest_room).is_final_room = true
