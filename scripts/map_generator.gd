extends Node2D

@onready var floor_map = $TileMap
var start_room = preload("res://scenes/rooms/start_room.tscn")
var torch  = preload("res://scenes/terrain/torch.tscn")

var room_pool = []
var enemies = [preload("res://scenes/enemies/mob.tscn"),
			   preload("res://scenes/enemies/skeleton.tscn"),
			   preload("res://scenes/enemies/necromancer.tscn")]

var enemy_weights = {preload("res://scenes/enemies/mob.tscn") : 1, 
				 preload("res://scenes/enemies/skeleton.tscn") : 2, 
				 preload("res://scenes/enemies/necromancer.tscn") : 10}

func _pad_num(num, length):
	var padded = '0'.repeat(length - len(str(num))) + str(num)
	return padded

func _preload_rooms(num_rooms, str_length):
	var path = "res://scenes/rooms/room_{room_num}.tscn"

	for i in range(1, num_rooms + 1):
		var room_num = self._pad_num(i, str_length)
		var new_path = path.format({"room_num" : room_num})
		
		# Load must be used for dynamic paths or whatevrr
		self.room_pool.append(load(new_path))

func _spawn_torches(torch_pos, coord_offset=Vector2.ZERO):
	for pos in torch_pos:
		var offset_pos = Vector2i(pos.x + coord_offset.x, pos.y + coord_offset.y)
		var global_pos = self.floor_map.map_to_local(offset_pos)
		var torch_instance = torch.instantiate()
		
		torch_instance.position = global_pos
		self.add_child(torch_instance)

func _spawn_enemies(spawn_pos, room_num: int, coord_offset=Vector2.ZERO):
	var monster_weight = clamp(int(room_num / 3), 1, 10) * 3
	var rng = RandomNumberGenerator.new()

	while monster_weight > 0:
		for pos in spawn_pos:
			if monster_weight == 0:
				break

			var spawnable_enemies = []

			for i in range(len(self.enemies)):
				if enemy_weights[enemies[i]] <= monster_weight:
					spawnable_enemies.append(self.enemies[i])

			var offset_pos = Vector2i(pos.x + coord_offset.x, pos.y + coord_offset.y)
			var global_pos = self.floor_map.map_to_local(offset_pos)
			var rand_num = rng.randi_range(0, len(spawnable_enemies) - 1)

			var enemy_instance = spawnable_enemies[rand_num].instantiate()
			
			enemy_instance.position = global_pos
			get_tree().current_scene.get_node("SortingLayer").add_child(enemy_instance)

			monster_weight -= enemy_weights[spawnable_enemies[rand_num]]


# Pool range is an array of the room numbers you want to include in the pool. num_rooms is how many rooms you wan tot generate.
func _generate_rooms(pool_range: Array, num_rooms: int, max_consecutive: int, source_id: int):
	var coord_offset = Vector2i(0, 0) # The x and y offset that all of the generated rooms have accumulated.
	var my_queue = Queue.new(max_consecutive)
	var room_instance = self.room_pool[0].instantiate() # Just here so that the if condition can execute and doesn't give errors.
	
	# ---------------- STARTINNG ROOM ------------------------ #
	var start_room_instance = self.start_room.instantiate()
	var tile_coords = start_room_instance.get_node("TileMap").get_used_cells(0)
		
	# Sets all of the tiles in the tile map
	for tile_pos in tile_coords:
		var atlas_coords = start_room_instance.get_node("TileMap").get_cell_atlas_coords(0, tile_pos)

		self.floor_map.set_cell(0, tile_pos, source_id, atlas_coords)

	start_room_instance.set_vars()
	self._spawn_torches(start_room_instance.torch_positions)
	# Computes the offset 
	coord_offset += Vector2i(start_room_instance.room_width + 1, start_room_instance.exit_height)
	# ---------------- STARTINNG ROOM ------------------------ #


	for i in range(num_rooms):
		var index_pool = pool_range.duplicate()
		
		# Removes all of the consecutive rooms in the pool that are also in the queue
		if not my_queue.is_empty():
			for index in my_queue.iterable():
				if index in index_pool:
					index_pool.erase(index)

		var rand_index = index_pool.pick_random()

		room_instance = self.room_pool[rand_index].instantiate()
		tile_coords = room_instance.get_node("TileMap").get_used_cells(0)

		coord_offset += Vector2i(0, -room_instance.entrance_height)
			
		# Sets all of the tiles in the tile map
		for tile_pos in tile_coords:
			var atlas_coords = room_instance.get_node("TileMap").get_cell_atlas_coords(0, tile_pos)
			var new_pos = tile_pos + coord_offset

			self.floor_map.set_cell(0, new_pos, source_id, atlas_coords)


		room_instance.set_vars()
		self._spawn_torches(room_instance.torch_positions, coord_offset)
		self._spawn_enemies(room_instance.enemey_spawn_positions, i, coord_offset)
		# Computes the offset 
		coord_offset += Vector2i(room_instance.room_width + 1, room_instance.exit_height)
		
		if my_queue.is_full():
			my_queue.dequeue()
		my_queue.push(rand_index)

# Called when the node enters the scene tree for the first time.
func _ready():
	self._preload_rooms(10, 3)
	self._generate_rooms(range(10), 20, 3, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

class Queue:
	var queue_array: Array = Array()
	## The maximum number of items that the queue will hold.
	var capacity: int

	func _init(cap):
		if cap > 0:
			self.capacity = cap
		else:
			self.capacity = int(INF) # 0 or negative means there is not capacity.
			

	func push(item):
		if len(self.queue_array) < self.capacity:
			self.queue_array.append(item)
			return 1
		else:
			return 0

	func has(item):
		return item in queue_array

	func peek():
		return self.queue_array.front()
	
	func is_full():
		return len(self.queue_array) == self.capacity

	func is_empty():
		return self.queue_array.is_empty()

	func dequeue():
		return self.queue_array.pop_front()

	func get_length():
		return len(self.queue_array)
	
	func iterable():
		return self.queue_array.duplicate()
