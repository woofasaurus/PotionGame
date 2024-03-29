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
	max_health = 500
	health = max_health
	prev_health = health

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
		drop_loot()
		queue_free()
	if health != prev_health:
		$HealthIndicatorPosition/HealthIndicatorText.text = str(health) + " / " + str(max_health)
		prev_health = health
	
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

func drop_loot():
	var droproll = randi() % 100
	
	var loot
	loot = loot_scene.instantiate()
	loot.global_position = position
	get_tree().current_scene.get_node("SortingLayer").add_child(loot)
	loot.set_loot("mundane")
	$"/root/Global".loot_count += 1
	if droproll < 5:
		loot.set_loot("epic")
	elif droproll < 25:
		loot.set_loot("rare")
	elif droproll < 50:
		loot.set_loot("uncommon")
	if droproll < 75: 
		loot.set_loot("common")
	
	for i in range (10):
		var gold = loot_scene.instantiate()
		gold.global_position = position - Vector2(randi()%400 - 200, randi() % 300 - 150)
		get_tree().current_scene.get_node("SortingLayer").add_child(gold)
		gold.set_loot("gold")
		$"/root/Global".loot_count += 1
