extends Node2D

@onready var floor_map = $TileMap

var start_room = preload("res://scenes/rooms/start_room.tscn")
var boss_room = preload("res://scenes/rooms/boss_room.tscn")
var torch  = preload("res://scenes/terrain/torch.tscn")

var room_pool = []

var tile_len: int = 0

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

func _spawn_creatures(spawn_points, room_weight, map_offset):
	while room_weight > 0:
		for spawner in spawn_points:
				if room_weight <= 0:
					break

				var global_center = spawner.get_position() + Vector2(map_offset[0], map_offset[1]) * self.tile_len
				
				room_weight -= spawner.spawn(room_weight, 100, self.get_tree().get_current_scene(), global_center, "SortingLayer")

func _load_room_children(map_offset: Vector2i, children, room_weight: int=0):
	var spawn_points = []

	for child in children:		
		if child.get_class() != "TileMap" and child.get_class() != "Spawner":
			child.get_parent().remove_child(child)
			
			# Converts it to the coord to the center.
			var new_pos = self.floor_map.map_to_local(self.floor_map.local_to_map(child.get_position())) \
			+ Vector2(map_offset[0], map_offset[1]) * self.tile_len

			child.set_position(new_pos)

			self.add_child(child)
		elif child.get_class() == "Spawner":
			spawn_points.append(child)

	self._spawn_creatures(spawn_points, room_weight, map_offset)

# Pool range is an array of the room numbers you want to include in the pool. num_rooms is how many rooms you wan tot generate.
func _generate_rooms(pool_range: Array, num_rooms: int, max_consecutive: int, source_id: int):
	var coord_offset = Vector2i(0, 0) # The x and y offset that all of the generated rooms have accumulated.
	var my_queue = Queue.new(max_consecutive)
	var room_instance = self.room_pool[0].instantiate() # Just here so that the if condition can execute and doesn't give errors.
	
	# ---------------- STARTINNG ROOM BEGINNING ------------------------ #
	var start_room_instance = self.start_room.instantiate()
	var children = start_room_instance.get_children()

	var tile_coords = start_room_instance.get_node("TileMap").get_used_cells(0)
		
	# Sets all of the tiles in the tile map
	for tile_pos in tile_coords:
		var atlas_coords = start_room_instance.get_node("TileMap").get_cell_atlas_coords(0, tile_pos)

		self.floor_map.set_cell(0, tile_pos, source_id, atlas_coords)

	self._load_room_children(Vector2i(0, 0), children)

	# Computes the offset 
	coord_offset += Vector2i(start_room_instance.room_width + 1, start_room_instance.exit_height)
	# ---------------- STARTINNG ROOM  END ---------------------------------- #

	for i in range(num_rooms):
		var index_pool = pool_range.duplicate()

		@warning_ignore("integer_division")
		var floor_weight = clamp(int(i / 3), 1, 10) * 3 
		
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

		children = room_instance.get_children()
		self._load_room_children(coord_offset, children, floor_weight)

		# Computes the offset 
		coord_offset += Vector2i(room_instance.room_width + 1, room_instance.exit_height)
		
		if my_queue.is_full():
			my_queue.dequeue()
		my_queue.push(rand_index)

	# ---------------- BOSS ROOM ------------------------ #
	var boss_room_instance = self.boss_room.instantiate()
	tile_coords = boss_room_instance.get_node("TileMap").get_used_cells(0)

	coord_offset += Vector2i(0, -boss_room_instance.entrance_height)
		
	# Sets all of the tiles in the tile map
	for tile_pos in tile_coords:
		var atlas_coords = boss_room_instance.get_node("TileMap").get_cell_atlas_coords(0, tile_pos)
		var new_pos = tile_pos + coord_offset

		self.floor_map.set_cell(0, new_pos, source_id, atlas_coords)

	children = boss_room_instance.get_children()
	self._load_room_children(coord_offset, children)
	# ---------------- BOSS ROOM ------------------------ #

# Called when the node enters the scene tree for the first time.
func _ready():
	self.tile_len = self.floor_map.map_to_local(Vector2i(1, 0))[0] - self.floor_map.map_to_local(Vector2i(0, 0))[0]
	
	self._preload_rooms(10, 3)
	self._generate_rooms(range(10), 10, 3, 2)


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
			self.capacity = int(INF) # 0 or negative means there is no capacity.
			

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
