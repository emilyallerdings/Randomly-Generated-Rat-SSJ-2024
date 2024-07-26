extends Node

var main = null

enum CollisionLayer{PLAYER = 8, ENEMY = 7}


func shoot_line(shooter, collision_layer, velocity, num, delay, bulletparams:BulletParams = null):
	if is_instance_valid(main):
		main.shoot_line(shooter, collision_layer, velocity, num, delay, bulletparams)

func shotgun(shooter, collision_layer, velocity, num, spread, speed_vary, slow_down, bulletparams:BulletParams = null):
	if is_instance_valid(main):
		main.shotgun(shooter, collision_layer, velocity, num, spread, speed_vary, slow_down, bulletparams)

func even_shotgun(shooter, collision_layer, velocity, num, spread, speed_vary, slow_down, bulletparams:BulletParams = null):
	if is_instance_valid(main):	
		#print(bulletparams.speed)
		main.even_shotgun(shooter, collision_layer, velocity, num, spread, speed_vary, slow_down, bulletparams)
