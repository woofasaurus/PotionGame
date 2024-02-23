extends Area2D
var speed
@export var scale_rate = 0.01
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += Vector2(cos(rotation),sin(rotation))*speed*delta
	scale += Vector2(scale_rate,scale_rate)
	modulate.a *= 0.99

func set_variables(_scale, _rotation, _speed):
	scale = Vector2(_scale,_scale)
	rotation = _rotation
	speed = _speed

func _on_area_entered(area):
	if area.is_in_group("mobs"):
		area.owner.health -= 50

func _on_death_timer_timeout():
	queue_free()
