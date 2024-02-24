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

func _generate_room(room_num):
	var room = room_pool[room_num - 1]
	var room_instance = room.instantiate()
	var tile_coords = room_instance.get_node("TileMap").get_used_cells(0)
	
	for tile_pos in tile_coords:
		var atlas_coords = room_instance.get_node("TileMap").get_cell_atlas_coords(0, tile_pos)
		self.floor_map.set_cell(0, tile_pos, 0, atlas_coords)

func _generate_room_two(room_num):
	var room = room_pool[room_num - 1]
	var room_instance = room.instantiate()
	var tile_coords = room_instance.get_node("TileMap").get_used_cells(0)
	
	for tile_pos in tile_coords:
		var atlas_coords = room_instance.get_node("TileMap").get_cell_atlas_coords(0, tile_pos)
		var new_pos = tile_pos + Vector2i(33, -1)

		self.floor_map.set_cell(0, new_pos, 0, atlas_coords)

# Pool range is an array of the room numbers you want to include in the pool. num_rooms is how many rooms you wan tot generate.
func _generate_rooms(pool_range: Array, num_rooms: int):
	var coord_offset = Vector2i(0, 0) # The x and y offset that all of the generated rooms have accumulated.
	var last_index = -1 # Intialized at -1, just means that it's the first go.
	var room_instance = self.room_pool[0].instantiate() # Just here so that the if condition can execute and doesn't give errors.
	
	for i in range(num_rooms):
		var index_pool = pool_range.duplicate()
		
		if last_index != -1:
			index_pool.erase(last_index)
		var rand_index = index_pool.pick_random()

		room_instance = self.room_pool[rand_index].instantiate()
		print(room_instance.entrance_height, " ", room_instance.exit_height)
		var tile_coords = room_instance.get_node("TileMap").get_used_cells(0)

		if last_index != -1:
			coord_offset += Vector2i(0, -room_instance.entrance_height)

		for tile_pos in tile_coords:
			var atlas_coords = room_instance.get_node("TileMap").get_cell_atlas_coords(0, tile_pos)
			var new_pos = tile_pos + coord_offset

			self.floor_map.set_cell(0, new_pos, 0, atlas_coords)

		coord_offset += Vector2i(room_instance.room_width + 1, room_instance.exit_height)
		last_index = rand_index

# Called when the node enters the scene tree for the first time.
func _ready():
	self._preload_rooms(11, 3)
	self._generate_rooms(range(11), 50)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
