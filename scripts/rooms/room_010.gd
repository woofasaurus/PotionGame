extends room

func set_vars():
	torch_positions = [Vector2i(4, 2), Vector2i(13 , 10 ), Vector2i(23, 17)]
	enemey_spawn_positions = [Vector2i(6, 7), Vector2i(18, 18)]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_vars()
