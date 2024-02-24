extends CharacterBody2D
signal dead
signal health_update #Rename, update health, notjust damage
signal cash_update
signal inventory_update
signal select_update

@export var potion_scene: PackedScene
var metabolizing = []
#Character stats
@export var speed = 400
@export var dodge_speed = 800
@export var max_health = 3
var throw_speed = 700;
var health = max_health
var prev_health = max_health
@export var inventory = [preload("res://potions/fire_breathing.tres"), preload("res://potions/water.tres"), preload("res://potions/water.tres")]
var inventory_index = 0
var cash = 0
var max_thirst = 100.0
var thirst = max_thirst
var drinking = false;

var trackpad_distance = 0;
var dodging = false
var can_dodge = true
var facing = Vector2(1,0) #preserves last direction of movement for dodging when stationary

var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	#Link for global reference
	$"/root/Global".register_player(self)
	$AnimationPlayer.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	thirst -= delta*2
	if thirst > max_thirst:
		thirst = max_thirst
	if thirst < 0:
		thirst = 0
		health -= delta
		health_update.emit(health)
	#region == Health Checks ==
	if health <= 0:
		dead.emit()
		queue_free()
	
	if health != prev_health:
		$PlayerHurtbox.set_collision_layer_value( 2, false )
		$PlayerHurtbox.set_collision_layer_value( 6, true )
		$FullSpriteSheet.hide()
		$InvulnerableTimer.start()
		health_update.emit(health)
		prev_health = health
#endregion
	
	
	if Input.is_action_just_pressed("throw") and not inventory.is_empty(): #Throw Potion
		throw_potion(inventory.pop_at(inventory_index))
		inventory_index = clamp(inventory_index, 0, inventory.size() - 1)
		if inventory.size() != 0:
			select_update.emit(inventory[inventory_index])
		else:
			select_update.emit(null)
	elif Input.is_action_just_pressed("drink") and not inventory.is_empty():
		drink_potion()
		select_update.emit(inventory[inventory_index])
		$Drinking.start();
		
	#region == Movement/Dodge ==
	if Input.is_action_just_pressed("dodge") and not dodging and can_dodge: #Dodge Roll
		$PlayerHurtbox.set_collision_layer_value( 2, false )
		$PlayerHurtbox.set_collision_layer_value( 6, true )
		velocity = facing * dodge_speed #increase velocity and dont change it until dodge is over
		dodging = true;
		$DodgeTimer.start()
	elif not dodging:
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
	
	move_and_slide()
	
	if dodging:
		if not $AnimationPlayer.current_animation == "dodge":
			$AnimationPlayer.play("dodge")
		if velocity.x != 0:
			$FullSpriteSheet.flip_h = velocity.x < 0
	elif velocity.length() != 0:
		if not $AnimationPlayer.current_animation == "walk":
			$AnimationPlayer.play("walk")
		if velocity.x != 0:
			$FullSpriteSheet.flip_h = velocity.x < 0
	elif not $AnimationPlayer.current_animation == "idle":
		$AnimationPlayer.play("idle")
#endregion

func _input(event):
	if event.is_action_pressed("scroll_up"): #Scroll Inventory
		inventory_index += 1
	elif event.is_action_pressed("scroll_down"):
		inventory_index += 1
	elif event is InputEventPanGesture:
		trackpad_distance += event.delta.y
		if (abs(trackpad_distance) > 5):
			inventory_index += sign(trackpad_distance)
			trackpad_distance = 0
	inventory_index = clamp(inventory_index, 0, inventory.size() - 1)
	if inventory.size() != 0:
			select_update.emit(inventory[inventory_index])
	else:
		select_update.emit(null)

func throw_potion(_potion_reference):
	var potion_projectile = potion_scene.instantiate()
	potion_projectile.global_position = $Head.global_position
	potion_projectile.set_variables(_potion_reference, (get_global_mouse_position() - $Head.global_position), throw_speed)
	get_tree().current_scene.add_child(potion_projectile)
	inventory_update.emit(inventory)

func drink_potion():
	thirst += inventory[inventory_index].satiation 
	metabolizing.push_back(inventory[inventory_index])
	inventory[inventory_index] = preload("res://potions/empty_potion.tres")
	await get_tree().create_timer(180.0).timeout
	metabolizing.pop_front().effect(self)
	
	#var potion_timer = Timer.new()
	#add_child(potion_timer)
	#potion_timer.wait_time = 10.0
	#potion_timer.one_shot = true
	#potion_timer.connect("timeout", metabolize_timeout)
	#potion_timer.start()

func _on_dodge_timer_timeout():
	dodging = false
	$PlayerHurtbox.set_collision_layer_value( 2, true )
	$PlayerHurtbox.set_collision_layer_value( 6, false )
	$DodgeCooldown.start()
	can_dodge = false

func _on_dodge_cooldown_timeout():
	can_dodge = true
	
func _on_invulnerable_timeout():
	$PlayerHurtbox.set_collision_layer_value( 2, true )
	$PlayerHurtbox.set_collision_layer_value( 6, false )
	$FullSpriteSheet.show()


func _on_drinking_timeout():
	drinking = false;
