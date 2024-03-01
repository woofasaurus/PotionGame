extends room

func set_vars():
	torch_positions = [Vector2i(5, 17), Vector2i(23, 2), Vector2i(12, 10)]
	enemey_spawn_positions = [Vector2i(5, 20), Vector2i(18, 7)]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_vars()
 
