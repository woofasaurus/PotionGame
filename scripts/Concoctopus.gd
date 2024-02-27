extends Mob

@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite2D

var spawned: bool = false
var slam_scene = preload("res://scenes/enemies/tentacle_slam.tscn")
var throw_scene = preload("res://scenes/enemies/tentacle_throw.tscn")
var corpse = false

func _ready():
	$CollisionShape2D.disabled = false
	
func idle():
	$AttackTimer.stop()

func pursue(): #FLEE?
	print("IMPOSSIBLE")

func attack():
	if $AttackTimer.is_stopped():
		$AttackTimer.start()

func _physics_process(_delta):
	print("BOSS HP: " + str(health))
	if health <= 0 and not corpse:
		print("DEAD")
		dead.emit(position, "common")
		animation.play("die")
		corpse = true
	
	if self.spawned and not corpse:
		match current_state:
			"idle":
				idle()
			"pursuing":
				pursue()
			"attacking":
				attack()
	set_animations()

func set_animations():
	sprite.flip_h = direction_to_target.x > 0
	
	if self.spawned and not corpse:
		match current_state:
			"idle":
				animation.play("idle")
			"pursuing":
				pass
			"attacking":
				animation.play("idle")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "spawn":
		self.spawned = true
	if anim_name == "die":
		$AttackRange.monitoring = false
	

func _on_attack_range_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		target = area.owner
		current_state = "attacking"

func _on_attack_range_area_exited(area):
	if area.get_name() == "PlayerHitbox":
		target = null
		current_state = "idle"

func _on_attack_timer_timeout():
	if !corpse:
		var slam = slam_scene.instantiate()
		slam.scale = self.scale
		slam.global_position = target.global_position + scale*Vector2(randf_range(-800,800), randf_range(-200,-600))
		if slam.global_position.x < target.global_position.x:
			slam.scale.x = -slam.scale.x
		get_tree().current_scene.get_node("SortingLayer").add_child(slam)
		
		var throw = throw_scene.instantiate()
		throw.scale = self.scale
		throw.global_position = target.global_position + scale*Vector2(randf_range(-1000,1000), randf_range(-1000,1000))
		
		var throw_direction = target.global_position - throw.get_node("PotionThrowOrigin").global_position
		throw.set_direction(throw_direction)
		if throw_direction.x < 0:
			throw.get_node("Sprite2D").flip_h = true
		get_tree().current_scene.get_node("SortingLayer").add_child(throw)


func _on_spawn_range_area_entered(area):
	if not self.spawned:
		animation.play("spawn")
