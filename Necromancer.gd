extends Mob

@onready var animation = $AnimationPlayer
@onready var sprite = $FullSpriteSheet

var spawned: bool = false
var skeleton_scene = preload("res://scenes/enemies/skeleton.tscn")
var flee = false
var facing = Vector2.ZERO

func _ready():
	max_health = 1000;
	health = max_health;
	speed = 300;

func idle():
	velocity = Vector2.ZERO

func pursue(): #FLEE?
	direction_to_target = target.get_position() - get_position()
	
	if flee:
		self.velocity = -direction_to_target.normalized() * speed
	else:
		self.velocity = direction_to_target.normalized() * speed

func attack():
	facing += Vector2(randf_range(1, -1), randf_range(1, -1)).normalized()*speed/5
	velocity = facing.normalized()*speed

func _physics_process(_delta):
	# print(current_state)
	
	if health <= 0:
		drop_loot()
		queue_free()
	if health != prev_health:
		$HealthIndicatorPosition/HealthIndicatorText.text = str(health) + " / " + str(max_health)
	
	#print(current_state)
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
	sprite.flip_h = velocity.x > 0
	animation.queue("walk")

func _on_animation_player_animation_changed(old_name, new_name):
	if old_name == "summon" and current_state != "idle":
		var mob = skeleton_scene.instantiate();
		mob.position = Vector2(randi() % 300, randi() % 300)*scale + global_position #Spawn randomly within 500 cube around necromancer
		# mob.connect('dead', decrement_goblin_coun
		get_tree().current_scene.get_node("SortingLayer").add_child(mob)

func _on_attack_duration_timeout():
	animation.clear_queue()
	print(animation.get_queue())
	animation.queue("summon")

#region Aggro Range
func _on_aggro_range_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		target = area.owner
		current_state = "pursuing"
		flee = true

func _on_aggro_range_area_exited(area):
	if area.get_name() == "PlayerHitbox":
		current_state = "attacking"
		flee = false

func _on_pursue_range_area_exited(area):
	if area.get_name() == "PlayerHitbox":
		target = null
		current_state = "idle"
#endregion

func _on_attack_range_area_exited(area):
	if area.get_name() == "PlayerHitbox":
		target = area.owner
		current_state = "pursuing"

func drop_loot():
	var droproll = randi() % 100
	
	var loot
	loot = loot_scene.instantiate()
	loot.global_position = position
	get_tree().current_scene.get_node("SortingLayer").add_child(loot)
	loot.set_loot("common")
	$"/root/Global".loot_count += 1
	if droproll < 5:
		loot.set_loot("legendary")
	elif droproll < 25:
		loot.set_loot("epic")
	elif droproll < 50:
		loot.set_loot("rare")
	if droproll < 75: 
		loot.set_loot("uncommon")
	
	for i in range (10):
		var gold = loot_scene.instantiate()
		gold.set_loot("gold")
		gold.global_position = position - Vector2(randi()%50 - 25, randi() % 25 + 10)
		get_tree().current_scene.get_node("SortingLayer").add_child(loot)
		$"/root/Global".loot_count += 1
	
	droproll = randi() % 100
	var chest = $"/root/Global".chest_reference.instantiate()
	if droproll < 25:
		chest = mimic_scene.instantiate()
	chest.global_position = position
	$SortingLayer.add_child(chest)
