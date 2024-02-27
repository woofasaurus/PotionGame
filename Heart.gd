extends Sprite2D

func add_hp(_hp):
	while (_hp > 0 and frame < 2):
		frame += 1
		_hp -= 1
	return _hp
