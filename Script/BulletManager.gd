extends Node

const BULLET = preload("res://scenes/bullet.tscn")

enum CollisionLayer{PLAYER = 1, ENEMY = 2}

func create_bullet(shooter, collision_layer, velocity, offset, position):
	
	var nbullet = BULLET.instantiate()
	nbullet.shooter = shooter
	nbullet.set_collision_mask_value(collision_layer, true)
	nbullet.position = position + velocity.normalized()*offset
	nbullet.velocity = velocity
	
	Globals.add_child_to_main(nbullet)
	
	return nbullet
	
func shotgun(shooter, collision_layer, velocity, num, spread, speed_vary, slow_down):
	for i in range(num):
		var rand = randi_range(-spread,spread)
		var rand_speed = randi_range(2 * speed_vary, speed_vary)
		var speed_diff:float = 1.0 - rand_speed/velocity.length()
		
		var nbullet = create_bullet(shooter, collision_layer, velocity.rotated(deg_to_rad(rand)) * speed_diff, 25, shooter.global_position)
