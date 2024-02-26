extends Area2D

var velocity = Vector2()


func adjust_params(dir_normalized, total_velocity, global_pos, flipped):
	self.global_position = global_pos
	self.velocity = Vector2(total_velocity, total_velocity) * dir_normalized

	self.rotation = dir_normalized.angle()

	if flipped:
		self.transform.x.x = 1
	else:
		self.transform.x.x = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	self.position += self.velocity * delta

func _on_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		area.owner.health -= 1

	self.queue_free()

	
