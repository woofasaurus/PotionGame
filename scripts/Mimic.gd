extends Mob

#region CHESTSTUFF
var popup_scene = preload("res://scenes/hud/popup_text.tscn")
var in_range = false
var open = false
var velocity_decay = 0.5

var options

func _ready():
	$PopupText.set_text("[R] to open")
	$PopupText.hide()
	$MobHurtbox.monitoring = false
	$MobHurtbox.monitorable = false
	current_state = "idle"
	speed = 1500
	max_health = 200
	health = max_health

func _input(event):
	if event.is_action_pressed("interact") and in_range and not open:
		target = $"/root/Global".player
		current_state = "attacking"
		$InteractZone.monitoring = false
		$InteractZone.monitorable = false
		$PopupText.hide()

func _on_interact_zone_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		$PopupText.show()
		in_range = true

func _on_interact_zone_area_exited(area):
	if area.get_name() == "PlayerHitbox":
		$PopupText.hide()
		in_range = false
#endregion


func idle():
	$MobHurtbox.monitoring = false
	$MobHurtbox.monitorable = false
	$InteractZone.monitoring = true
	$InteractZone.monitorable = true
	velocity = Vector2.ZERO

func pursue():
	print("IMPOSSIBLE")

func attack():
	if not attacking:
		attacking = true
		direction_to_target = target.get_position() - get_position()
		$TimeTillLunge.start()
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
	
	set_animations()
	move_and_slide()

func set_animations():
	match current_state:
		"idle":
			$AnimationPlayer.play("idle")
		"pursuing":
			pass
		"attacking":
			$AnimationPlayer.play("attack")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "attack":
		attacking = false

func _on_time_till_lunge_timeout():
	if target != null:
		direction_to_target = target.get_position() - get_position()
		velocity = direction_to_target.normalized()*speed

func _on_time_till_hurtbox_timeout():
	$MobHurtbox.monitoring = true
	$MobHurtbox.monitorable = true
	velocity *= velocity_decay

func _on_mob_hurtbox_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		area.owner.health -= 1

func _on_attack_duration_timeout():
	$MobHurtbox.monitoring = false
	$MobHurtbox.monitorable = false
	velocity = Vector2.ZERO

#region Aggro Range
func _on_pursue_range_area_exited(area):
	if area.get_name() == "PlayerHitbox":
		target = null
		current_state = "idle"
#endregion
