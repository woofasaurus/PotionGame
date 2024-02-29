extends room

func set_vars():
	torch_positions = [Vector2i(5, 2), Vector2i(12, 2), Vector2i(20, 2)]
	enemey_spawn_positions = [Vector2i(7, 7), Vector2i(23, 22)]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_vars()
