extends CPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(dir):
	self.direction = dir
	self.emitting = true


func _on_finished():
	queue_free()
	pass # Replace with function body.
