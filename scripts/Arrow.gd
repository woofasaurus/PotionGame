extends Area2D

var velocity = Vector2(1,0)


func adjust_params(dir_normalized, total_velocity, global_pos, flipped):
	self.global_position = global_pos
	self.velocity = Vector2(total_velocity, total_velocity) * dir_normalized
	
	self.global_rotation = dir_normalized.angle()
	
	#if flipped:
	#	self.transform.x.x = 1
	#else:
	#	self.transform.x.x = -1

func _process(delta):
	self.position += self.velocity * delta

func _on_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		area.owner.health -= 1
	self.queue_free()

func _on_body_entered(body):
	if body.get_name() == "TileMap":
		#queue_free()
		pass
