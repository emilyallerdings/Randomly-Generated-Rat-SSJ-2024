extends HSlider

const gutsplode_sound = preload("res://assets/gutsplode.ogg")

# Called when the node enters the scene tree for the first time.
func _ready():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),(self.value) - 5.0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_drag_ended(val_changed):

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), (self.value) - 5.0)
	
	var gutsplode = FreeAudio.new(gutsplode_sound, 5)
	add_child(gutsplode)
	pass # Replace with function body.
