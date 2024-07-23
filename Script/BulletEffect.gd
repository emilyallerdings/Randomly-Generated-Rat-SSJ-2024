extends CPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(dir, color):
	self.direction = dir
	self.color_ramp.set_color(0, color)
	self.emitting = true


func _on_finished():
	queue_free()
	pass # Replace with function body.
