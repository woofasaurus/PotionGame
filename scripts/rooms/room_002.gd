extends room

func set_vars():
	torch_positions = [Vector2i(4, 12), Vector2i(31, 12), Vector2i(17, 2), Vector2i(18, 2)]
	enemey_spawn_positions = [Vector2i(17, 8), Vector2i(17, 27)]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_vars()
