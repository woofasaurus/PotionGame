extends room

func set_vars():
	torch_positions = [Vector2i(3, 1), Vector2i(15, 2), Vector2i(30, 1)]
	enemey_spawn_positions = [Vector2i(11, 4), Vector2i(23, 4)]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_vars()
