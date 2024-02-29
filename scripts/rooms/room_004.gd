extends room

func set_vars():
	torch_positions = [Vector2i(3, 0), Vector2i(18, 0 ), Vector2i(10, 17)]
	enemey_spawn_positions = [Vector2i(5, 12), Vector2i(16, 12)]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_vars()
