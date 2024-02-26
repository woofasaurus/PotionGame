extends Mob

@onready var animation = $AnimationPlayer
@onready var sprite = $FullSpriteSheet

var spawned: bool = false

func idle():
	velocity = Vector2.ZERO

func pursue():
	direction_to_target = target.get_position() - get_position()
	velocity = direction_to_target.normalized()*speed

func attack():
	if not attacking:
		attacking = true
		$TimeTillHurtbox.start()
		$AttackDuration.start()

func _physics_process(_delta):
	if health <= 0:
		dead.emit(position, "common")
		
		queue_free()
	
	# print(current_state)
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
	match current_state:
		"idle":
			pass
		"pursuing":
			if not self.spawned:
				animation.play("spawn")
			else:
				animation.play("walk")
				sprite.flip_h = direction_to_target.x > 0
		"attacking":
			if self.spawned:
				animation.play("attack")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "spawn":
		self.spawned = true

func _on_attack_duration_timeout():
	attacking = false;

func _on_time_till_hurtbox_timeout():
	var slash = slash_scene.instantiate()
	slash.global_position = $SwingPoint.global_position
	slash.rotation = direction_to_target.angle()
	slash.get_node("AnimatedSprite2D").flip_v = $FullSpriteSheet.flip_h
	get_tree().current_scene.add_child(slash)

#region Aggro Range
func _on_aggro_range_area_entered(area):
	print(area)
	if area.get_name() == "PlayerHitbox":
		target = area.owner
		current_state = "pursuing"

func _on_pursue_range_area_exited(area):
	print(area)
	if area.get_name() == "PlayerHitbox":
		target = null
		current_state = "idle"
#endregion

func _on_attack_range_area_entered(area):
	print(area)
	if area.get_name() == "PlayerHitbox":
		target = area.owner
		current_state = "attacking"

func _on_attack_range_area_exited(area):
	print(area)
	if area.get_name() == "PlayerHitbox":
		target = area.owner
		current_state = "pursuing"
