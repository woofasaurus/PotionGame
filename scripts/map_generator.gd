extends Node2D

var room_pool = []

func _pad_num(num, length):
	var padded = '0'.repeat(length - len(str(num))) + str(num)
	return padded


func _preload_rooms(num_rooms, length):
	var path = "res://scenes/rooms/room_{room_num}.tscn"

	for i in range(num_rooms):
		var room_num = self._pad_num(i, length)
		var new_path = path.format({"room_num" : room_num})
		
		# Load must be used for dynamic paths or whatevrr
		self.room_pool.append(load(new_path))

# Called when the node enters the scene tree for the first time.
func _ready():
	self._preload_rooms(3, 3)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
