extends Node2D

@onready var floor_map = $TileMap

var room_pool = []

func _pad_num(num, length):
	var padded = '0'.repeat(length - len(str(num))) + str(num)
	return padded


func _preload_rooms(num_rooms, length):
	var path = "res://scenes/rooms/room_{room_num}.tscn"

	for i in range(1, num_rooms + 1):
		var room_num = self._pad_num(i, length)
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

# Called when the node enters the scene tree for the first time.
func _ready():
	self._preload_rooms(3, 3)
	self._generate_room(1)
	self._generate_room_two(2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
