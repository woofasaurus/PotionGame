extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	$Timer.start()

func _on_timer_timeout():
	queue_free()

func _on_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		area.owner.health -= 1
	if area.is_in_group("mobs"):
		area.owner.health -= 100
