extends Sprite2D

func add_hp(_hp):
	while (_hp > 0 and frame > 0): #No half heart max
		frame -= 2
		_hp -= 1
	return _hp

func lose_hp(_hp):
	while (_hp > 0 and frame < 2):
		frame += 2
		_hp -= 1
	return _hp

func set_zero():
	frame = 2
