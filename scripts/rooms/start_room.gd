extends room

func set_vars():
	torch_positions = [Vector2i(4, 2), Vector2i(11, 2)]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.set_vars()
