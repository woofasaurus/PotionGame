extends room

func set_vars():
	torch_positions = [Vector2i(4, 4), Vector2i(15, 9 ), Vector2i(15, -3), Vector2(27, 4)]
	enemey_spawn_positions = [Vector2i(9, 6), Vector2i(21, 6)]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_vars()
