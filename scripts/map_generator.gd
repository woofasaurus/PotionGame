extends Node2D

@onready var floor_map = $TileMap

var room_pool = []

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

# Pool range is an array of the room numbers you want to include in the pool. num_rooms is how many rooms you wan tot generate.
func _generate_rooms(pool_range: Array, num_rooms: int, max_consecutive: int):
	var coord_offset = Vector2i(0, 0) # The x and y offset that all of the generated rooms have accumulated.
	var my_queue = Queue.new(max_consecutive)
	var room_instance = self.room_pool[0].instantiate() # Just here so that the if condition can execute and doesn't give errors.
	
	for i in range(num_rooms):
		var index_pool = pool_range.duplicate()
		
		# Removes all of the consecutive rooms in the pool that are also in the queue
		if not my_queue.is_empty():
			for index in my_queue.iterable():
				if index in index_pool:
					index_pool.erase(index)

		var rand_index = index_pool.pick_random()

		room_instance = self.room_pool[rand_index].instantiate()
		var tile_coords = room_instance.get_node("TileMap").get_used_cells(0)

		# Adds the offset
		if not my_queue.is_empty():
			coord_offset += Vector2i(0, -room_instance.entrance_height)
			
		# Sets all of the tiles in the tile map
		for tile_pos in tile_coords:
			var atlas_coords = room_instance.get_node("TileMap").get_cell_atlas_coords(0, tile_pos)
			var new_pos = tile_pos + coord_offset

			print(atlas_coords, " ", new_pos)

		# Computes the offset 
		coord_offset += Vector2i(room_instance.room_width + 1, room_instance.exit_height)
		
		if my_queue.is_full():
			my_queue.dequeue()
		my_queue.push(rand_index)

# Called when the node enters the scene tree for the first time.
func _ready():
	self._preload_rooms(11, 3)
	self._generate_rooms(range(11), 50, 3)


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
