extends Node2D
var fire_projectile_scene = preload("res://scenes/effect_scenes/fire_projectile.tscn") 

func _ready():
	$SpawnFire.start()
	
func _on_spawn_fire_timeout():
	var direction = get_global_mouse_position() - global_position;
	rotation = direction.angle()
	var fire_projectile = fire_projectile_scene.instantiate()
	fire_projectile.position = global_position + direction.normalized()*50
	fire_projectile.set_variables(0.5, rotation + randf()*PI/6 - PI/12, 500)
	get_tree().current_scene.add_child(fire_projectile)


func _on_death_timer_timeout():
	queue_free()
