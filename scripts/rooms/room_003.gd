extends room

func set_vars():
	torch_positions = [Vector2i(9, 14), Vector2i(38, 14), Vector2i(9, 30), Vector2i(38, 30)]
	enemey_spawn_positions = [Vector2i(13, 18), Vector2i(33, 18)]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_vars()
