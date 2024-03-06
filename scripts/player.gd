extends CharacterBody2D

#region Signals
signal dead
signal health_update #Rename, update health, notjust damage
signal cash_update
signal inventory_update
#endregion

#Character stats

#region Health Variables
@export var max_health = 3
var health = max_health
var prev_health = max_health
#endregion

#region Thirst Variables
var max_thirst = 100.0
var thirst = max_thirst
#endregion

#region Movement Variables
@export var speed = 400

@export var dodge_speed = 800
var dodging = false
var can_dodge = true
var facing = Vector2(1,0) #preserves last direction of movement for dodging when stationary
#endregion

#region Drink/Throw Variables
var throw_speed = 700;

var potion_scene = preload("res://scenes/projectiles/potion_projectile.tscn")
var metabolizing = []
var aiming = false
var melee = false
var melee_scale = 1
#endregion

#region Inventory Variables
var cash = 200
#region StartingInventory
var inventory_wheel_scene= preload("res://scenes/hud/inventory_wheel.tscn")
var inventory;
#endregion StartingInventory
#endregion

#region Other
var trackpad_distance = 0;
#endregion




# Called when the node enters the scene tree for the first time.
func _ready():
	#Link for global reference
	$"/root/Global".register_player(self)
	$AnimationPlayer.play("idle")
	$PotionThrowOrigin.hide()
	inventory = inventory_wheel_scene.instantiate()
	get_tree().current_scene.get_node("HUD").add_child(inventory)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#region Thirst Checks
	thirst -= delta
	if thirst > max_thirst:
		thirst = max_thirst
	if thirst < 0:
		thirst = 0
		health -= 1
		health_update.emit(health, max_health)
	#endregion
	
	#region == Health Checks ==
	if health <= 0:
		dead.emit()
		get_tree().call_group("mobs", "queue_free")
		queue_free()
		pass
	
	if health != prev_health:
		if health < prev_health:
			$PlayerHitbox.set_collision_layer_value( 2, false )
			$PlayerHitbox.set_collision_layer_value( 6, true )
			$FullSpriteSheet.hide()
			$InvulnerableTimer.start()
		health_update.emit(health, max_health)
		prev_health = health
#endregion
	
	#region == Drink/Throw ==
	if Input.is_action_pressed("throw") and not inventory.is_empty(): #Aim Potion
		aiming = true
		$PotionThrowOrigin.rotation = (get_global_mouse_position() - $PotionThrowOrigin.global_position).angle()
		$PotionThrowOrigin.show()
	
	if Input.is_action_just_released("throw") and aiming:
		aiming = false
		$PotionThrowOrigin.hide()
		throw_potion(inventory.pop_selected())
		
	elif Input.is_action_just_pressed("drink") and not inventory.is_empty():
		drink_potion()
	
	#endregion
	
	#region == Movement and Animations ==
	if Input.is_action_just_pressed("dodge") and not dodging and can_dodge: #Dodge Roll
		begin_dodge()
	elif not dodging:
		velocity_to_key_press_direction()
	
	move_and_slide()
	
	set_animation()
	#endregion

#region MOVEMENT HELPER FUNCTIONS
func velocity_to_key_press_direction():
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		facing = velocity.normalized() #preserves last direction of movement for dodging when stationary

func begin_dodge(): #start dodge
	$PlayerHitbox.set_collision_layer_value( 2, false )
	$PlayerHitbox.set_collision_layer_value( 6, true )
	set_collision_mask_value( 8, false ) 
	velocity = facing * dodge_speed #increase velocity and dont change it until dodge is over
	dodging = true;
	$DodgeTimer.start()

func _on_dodge_timer_timeout(): #end dodge
	dodging = false
	$PlayerHitbox.set_collision_layer_value( 2, true )
	$PlayerHitbox.set_collision_layer_value( 6, false )
	set_collision_mask_value( 8, true )
	$DodgeCooldown.start()
	can_dodge = false

func _on_dodge_cooldown_timeout(): #can dodge again
	can_dodge = true

#endregion

func _on_invulnerable_timeout(): #i-frames after being hit
	$PlayerHitbox.set_collision_layer_value( 2, true )
	$PlayerHitbox.set_collision_layer_value( 6, false )
	$FullSpriteSheet.show()

#region Potion Throw/Drink
func throw_potion(_potion_reference):
	var potion_projectile = potion_scene.instantiate()
	potion_projectile.global_position = $PotionThrowOrigin.global_position
	potion_projectile.set_variables(_potion_reference, (get_global_mouse_position() - $PotionThrowOrigin.global_position), throw_speed)
	get_tree().current_scene.add_child(potion_projectile)
	
	if melee:
		var slash = preload("res://scenes/projectiles/slash.tscn").instantiate()
		slash.global_position = $PotionThrowOrigin.global_position
		slash.rotation = (get_global_mouse_position() - $PotionThrowOrigin.global_position).angle()
		slash.get_node("AnimatedSprite2D").flip_v = $FullSpriteSheet.flip_h
		slash.set_collision_mask_value( 2, false )
		slash.set_collision_mask_value( 3, true )
		slash.scale *= melee_scale
		get_tree().current_scene.add_child(slash)

func drink_potion():
	var _drink_ref = inventory.pop_drink()
	thirst += _drink_ref.satiation 
	metabolizing.push_back(_drink_ref)
	await get_tree().create_timer(180.0).timeout
	metabolizing.pop_front().effect(self)
#endregion

func set_animation():
	if dodging: #DODGE ANIMATION
		if not $AnimationPlayer.current_animation == "dodge": #if not dodging, start dodge animatino
			$AnimationPlayer.play("dodge")
		if velocity.x != 0: #ensures that it doesnt autoswitch direction when stopped
			$FullSpriteSheet.flip_h = velocity.x < 0
	
	elif velocity.length() != 0: #WALK ANIMATION
		if not $AnimationPlayer.current_animation == "walk":
			$AnimationPlayer.play("walk")
		if velocity.x != 0: #ensures that it doesnt autoswitch direction when stopped
			$FullSpriteSheet.flip_h = velocity.x < 0
	
	
	elif not $AnimationPlayer.current_animation == "idle": #IDLE ANIMATION
		$AnimationPlayer.play("idle")
