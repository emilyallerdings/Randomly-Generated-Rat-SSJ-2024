extends Control
const BLOOD_PARTICLES = preload("res://Scenes/blood_particles.tscn")
const SMOKE_PARTICLES = preload("res://smoke_particles.tscn")
const BULLET_EFFECT = preload("res://Scenes/BulletEffect.tscn")
const PLAY_GAME = "res://Scenes/main.tscn"
# Called when the node enters the scene tree for the first time.
func _ready():
	
	#AudioServer.set_bus_volume_db(0, 0.1)
	
	spawn_particles()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass # Replace with function body.


func spawn_particles():
	
	await get_tree().create_timer(0.15).timeout
	var presmoke = SMOKE_PARTICLES.instantiate()
	add_child(presmoke)
	presmoke.emitting = true
	
	await get_tree().create_timer(0.15).timeout
	var preblood = BLOOD_PARTICLES.instantiate()
	add_child(preblood)
	preblood.emitting = true
	
	await get_tree().create_timer(0.15).timeout
	var prebullet = BULLET_EFFECT.instantiate()
	add_child(prebullet)
	prebullet.emitting = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	get_tree().change_scene_to_file(PLAY_GAME)
	pass # Replace with function body.


func _on_button_2_pressed():
	get_tree().quit()
	pass # Replace with function body.
