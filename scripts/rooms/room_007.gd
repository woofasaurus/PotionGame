extends room

func set_vars():
	torch_positions = [Vector2i(6, 3), Vector2i(13, 9 ), Vector2i(12, 17)]
	enemey_spawn_positions = [Vector2i(17, 8), Vector2i(17, 14)]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_vars()
