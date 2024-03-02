extends CharacterBody2D

class_name Mob

signal dead

#region AI Variables
const STATES = ["idle", "pursuing", "attacking"]
var current_state = "idle"
var target = null
var direction_to_target = Vector2.ZERO

var slash_scene = preload("res://scenes/projectiles/slash.tscn")
var loot_scene = preload("res://scenes/loot.tscn")
var mimic_scene = preload("res://scenes/enemies/mimic.tscn")
var attacking = false
#endregion

#region stat variables
@export var speed = 250;
@export var max_health = 100;
var health = max_health;
var prev_health = health;
#endregion

func _ready():
	$CollisionShape2D.disabled = false

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
			pass
		"pursuing":
			$AnimationPlayer.play("walk")
			$FullSpriteSheet.flip_h = direction_to_target.x < 0
		"attacking":
			$AnimationPlayer.play("attack")

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
		current_state = "attacking"

func _on_attack_range_area_exited(area):
	if area.get_name() == "PlayerHitbox":
		target = area.owner
		current_state = "pursuing"

func drop_loot():
	
	for i in range (2):
		var droproll = randi() % 100
		
		var loot
		loot = loot_scene.instantiate()
		loot.global_position = position
		get_tree().current_scene.get_node("SortingLayer").add_child(loot)
		loot.set_loot("mundane")
		$"/root/Global".loot_count += 1
		
		if droproll < 10:
			loot.set_loot("rare")
		elif droproll < 20:
			loot.set_loot("uncommon")
		elif droproll < 70:
			loot.set_loot("common")
	
	var gold = loot_scene.instantiate()
	gold.global_position = position - Vector2(randi()%50 - 25, randi() % 25 + 10)
	get_tree().current_scene.get_node("SortingLayer").add_child(gold)
	gold.set_loot("gold")
	$"/root/Global".loot_count += 1
