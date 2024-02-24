extends CharacterBody2D
signal dead

var slash_scene = preload("res://scenes/projectiles/slash.tscn")

@export var speed = 250;
@export var health = 100;

var player_relative_position = Vector2.ZERO
var attacking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D.disabled = false
	$AnimatedSprite2D.play()

func _physics_process(_delta):
	if health <= 0:
		dead.emit(position, "common")
		
		queue_free()
	
	if $"/root/Global".player != null and not attacking:
		player_relative_position = $"/root/Global".player.get_position() - get_position()
	
	velocity = player_relative_position
	if velocity.length() > 100 and not attacking:
		$AnimatedSprite2D.animation = "run"
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif not attacking: #Attack!
		attacking = true
		$AnimatedSprite2D.flip_h = player_relative_position.x < 0
		$AnimatedSprite2D.animation = "attack"
		$TimeTillHurtbox.start()
		$AttackDuration.start()
	
	move_and_slide()

func _on_mob_hurtbox_area_entered(area): #Check this
	print(area.get_name())
	if area.get_name() == "PlayerHurtbox":
		area.owner.health -= 0.5

func _on_attack_duration_timeout():
	attacking = false;

func _on_time_till_hurtbox_timeout():
	var slash = slash_scene.instantiate()
	slash.global_position = $SwingPoint.global_position
	slash.rotation = player_relative_position.angle()
	slash.get_node("AnimatedSprite2D").flip_v = $AnimatedSprite2D.flip_h
	get_tree().current_scene.add_child(slash)
