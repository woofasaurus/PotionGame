extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	self.volume_db = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.volume_db < 0:
		self.volume_db += 5 * delta
	else:
		self.volume_db = clamp(self.volume_db, -1, 0)

func _on_finished():
	self.volume_db = -20
	self.play(0.0) # Loops now,
