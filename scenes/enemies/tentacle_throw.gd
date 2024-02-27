extends StaticBody2D

var concoctopus_potion_scene = preload("res://scenes/projectiles/concoctopus_projectile.tscn")
var direction
var throw_speed = 1400

func _ready():
	$AnimationPlayer.play("throw")

func set_direction(_dir):
	direction = _dir

func _on_throw_timer_timeout():
	var potion_projectile = concoctopus_potion_scene.instantiate()
	potion_projectile.scale = self.scale*2
	potion_projectile.global_position = $PotionThrowOrigin.global_position
	potion_projectile.set_variables(direction, throw_speed)
	get_tree().current_scene.add_child(potion_projectile)

func _on_animation_player_animation_finished(anim_name):
	queue_free()
