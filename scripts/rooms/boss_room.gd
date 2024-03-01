extends room

func set_vars():
	torch_positions = []
	enemey_spawn_positions = [Vector2i(20, 15)]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_vars()
