extends Mob

@onready var animation = $AnimationPlayer
@onready var sprite = $FullSpriteSheet

var spawned: bool = false
var arrow_scene = preload("res://scenes/projectiles/arrow.tscn")
var arrow_fired = false
var flee = false

func _ready():
	max_health = 300;
	health = max_health;
	prev_health = health
	speed = 200;

func idle():
	velocity = Vector2.ZERO

func pursue(): #FLEE?
	direction_to_target = target.get_position() - get_position()
	
	if flee:
		self.velocity = -direction_to_target.normalized() * speed
	else:
		self.velocity = direction_to_target.normalized() * speed

func attack():
	if not attacking:
		self.velocity = Vector2.ZERO
		attacking = true
		$TimeTillHurtbox.start()
		$AttackDuration.start()

func _physics_process(_delta):
	# print(current_state)
	
	if health <= 0:
		drop_loot()
		queue_free()
	if health != prev_health:
		$HealthIndicatorPosition/HealthIndicatorText.text = str(health) + " / " + str(max_health)
		prev_health = health
	
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
	
	if self.spawned:
		match current_state:
			"idle":
				animation.play("idle")
			"pursuing":
				animation.clear_queue()
				if flee:
					animation.play_backwards("walk")
				else:
					animation.play("walk")
			"attacking":
				if not arrow_fired:		
					direction_to_target = target.get_position() - get_position()
					animation.play("attack")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "spawn":
		self.spawned = true
	if anim_name == "attack":
		animation.play("idle")

func _on_attack_duration_timeout():
	attacking = false
	arrow_fired = false

func _on_time_till_hurtbox_timeout():
	if target != null:
		var arrow = arrow_scene.instantiate()
		arrow_fired = true
		var arrow_direction = (target.get_position() - $ArrowSpawn.global_position).normalized()
		var arrow_spawn_position = $ArrowSpawn.global_position + Vector2(400*self.scale.x, 400*self.scale.x) * arrow_direction
		 
		arrow.adjust_params(arrow_direction, 2000, arrow_spawn_position, sprite.flip_h)
		get_tree().current_scene.add_child(arrow)
	else:
		current_state = "idle"

#region Aggro Range
func _on_aggro_range_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		target = area.owner
		current_state = "pursuing"
		flee = true

func _on_aggro_range_area_exited(area):
	if area.get_name() == "PlayerHitbox":
		self.velocity = Vector2.ZERO
		current_state = "attacking"
		animation.play("idle")
		flee = false

func _on_pursue_range_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		animation.play("spawn")


func _on_pursue_range_area_exited(area):
	if area.get_name() == "PlayerHitbox":
		target = null
		current_state = "idle"
#endregion

func _on_attack_range_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		target = area.owner
		current_state = "attacking"

func _on_attack_range_area_exited(area):
	if area.get_name() == "PlayerHitbox":
		target = area.owner
		current_state = "pursuing"

func drop_loot():
	
	for i in range(3):
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
	
	for i in range (3):
		var gold = loot_scene.instantiate()
		gold.global_position = position - Vector2(randi()%200 - 100, randi() % 200 - 50)
		get_tree().current_scene.get_node("SortingLayer").add_child(gold)
		gold.set_loot("gold")
		$"/root/Global".loot_count += 1
