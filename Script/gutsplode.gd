extends AudioStreamPlayer
class_name FreeAudio

func _init(audio_source):
	self.stream = audio_source

# Called when the node enters the scene tree for the first time.
func _ready():
	play(0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_finished():
	queue_free()
	pass # Replace with function body.
