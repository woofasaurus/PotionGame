extends room

func set_vars():
	torch_positions = [Vector2i(6, 14), Vector2i(8, 6 ), Vector2i(15, 0)]
	enemey_spawn_positions = [Vector2i(12, 12), Vector2i(3, 5)]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_vars()
