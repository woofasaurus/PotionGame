extends Mob

@onready var animation = $AnimationPlayer
@onready var sprite = $FullSpriteSheet

var spawned: bool = false
var arrow_scene = preload("res://scenes/projectiles/arrow.tscn")

func idle():
	velocity = Vector2.ZERO

func pursue():
	direction_to_target = target.get_position() - get_position()
	
	if direction_to_target.length() > 500 and current_state == "pursuing":
		self.velocity = Vector2.ZERO
		current_state = "attacking"
	# Walks backwards if the target is 500 or less units away
	else:
		self.velocity = -direction_to_target.normalized() * speed
		

func attack():
	if not attacking:
		self.velocity = Vector2.ZERO
		attacking = true
		$TimeTillHurtbox.start()
		$AttackDuration.start()

func _physics_process(_delta):
	# print(current_state)
	
	if health <= 0:
		dead.emit(position, "common")
		
		queue_free()
	
	# print(current_state)
	if self.spawned:
		match current_state:
			"idle":
				idle()
			"pursuing":
				pursue()
			"attacking":
				attack()
	
	if not self.spawned:
		self.velocity = Vector2.ZERO

	set_animations()
	move_and_slide()

func set_animations():
	sprite.flip_h = direction_to_target.x > 0
	
	match current_state:
		"idle":
			pass
		"pursuing":
			if not self.spawned:
				animation.play("spawn")
			else:
				animation.play_backwards("walk")
		"attacking":
			if self.spawned:
				animation.play("attack")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "spawn":
		self.spawned = true

func _on_attack_duration_timeout():
	attacking = false
	current_state = "pursuing"

func _on_time_till_hurtbox_timeout():
	print('arrow')
	var arrow = arrow_scene.instantiate()

	arrow.adjust_params((target.get_position() - $ArrowSpawn.global_position).normalized(), 2000, $ArrowSpawn.global_position, sprite.flip_h)
	get_tree().current_scene.add_child(arrow)

#region Aggro Range
func _on_aggro_range_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		target = area.owner
		current_state = "pursuing"

func _on_pursue_range_area_exited(area):
	if area.get_name() == "PlayerHitbox":
		target = null
		current_state = "idle"
#endregion

func _on_attack_range_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		target = area.owner
		current_state = "pursuing"

func _on_attack_range_area_exited(area):
	if area.get_name() == "PlayerHitbox":
		target = area.owner
		current_state = "pursuing"
