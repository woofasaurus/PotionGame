extends StaticBody2D

func _ready():
	$AnimationPlayer.play("slam")
	$Hurtbox.monitoring = false
	$Hurtbox.monitorable = false

func _on_slam_timer_timeout():
	$Hurtbox.monitoring = true
	$Hurtbox.monitorable = true

func _on_hurtbox_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		area.owner.health -= 100

func _on_slam_end_timeout():
	$Hurtbox.monitoring = false
	$Hurtbox.monitorable = false

func _on_animation_player_animation_finished(anim_name):
	queue_free()
