extends StaticBody2D

var num_arm_animations = 4
var for_sale_scene = preload("res://scenes/npcs/potion_seller/for_sale.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$IdleAnimation.play("Idle")
	random_animation($ArmAnimation1)
	random_animation($ArmAnimation2)
	random_animation($ArmAnimation1)
	random_animation($ArmAnimation2)
	var potion_one = for_sale_scene.instantiate()
	potion_one.set_variables(preload("res://potions/health_potion.tres"), 50)
	potion_one.position = $Potion1.position
	var potion_two = for_sale_scene.instantiate()
	add_child(potion_one)
	potion_two.set_variables(preload("res://potions/slowness.tres"), 10)
	potion_two.position = $Potion2.position
	var potion_three = for_sale_scene.instantiate()
	add_child(potion_two)
	potion_three.set_variables(preload("res://potions/fire_breathing.tres"), 100)
	potion_three.position = $Potion3.position
	add_child(potion_three)

func random_animation(_arm):
	var roll = randi() % num_arm_animations
	match roll:
		0:
			_arm.queue("Egg")
		1:
			_arm.queue("Scratch")
		2:
			_arm.queue("Salt")
		3:
			_arm.queue("Pixie")

func _on_arm_animation_1_animation_changed(old_name, new_name):
	if (new_name == $ArmAnimation2.get_current_animation()):
		random_animation($ArmAnimation1)
		$ArmAnimation1.play($ArmAnimation1.get_queue()[0])
		print($ArmAnimation2.get_queue())
	random_animation($ArmAnimation1)


func _on_arm_animation_2_animation_changed(old_name, new_name):
	if (new_name == $ArmAnimation1.get_current_animation()):
		random_animation($ArmAnimation2)
		print($ArmAnimation2.get_queue())
		$ArmAnimation2.play($ArmAnimation2.get_queue()[0])
	random_animation($ArmAnimation2)
