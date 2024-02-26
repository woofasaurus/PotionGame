extends Area2D

var velocity = Vector2()


func adjust_params(rot, total_velocity):
	self.rotation = rot
	self.velocity = Vector2(total_velocity * cos(rot), total_velocity * sin(rot))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _process(delta):
	self.position += self.velocity * delta

func _on_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		area.owner.health -= 1

	self.queue_free()

	
