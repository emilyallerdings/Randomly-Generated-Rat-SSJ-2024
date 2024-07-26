extends Area2D

@onready var icon = $Sprite2D

var damage = 1
var duration = 5
var creator

var alpha = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	print("POOP")
	if creator:
		icon.modulate = creator.color
		$Glow.modulate = creator.color

		#icon.modulate.a = 1.0
		#icon.self_modulate = creator.self_modulate
		self.scale = creator.scale * 6
		self.damage = creator.damage / 5
	start_damage()
	pass # Replace with function body.

func set_creator(creator):
	self.creator = creator

func start_damage():
	while(true):
		duration -= 1
		
		var hitevent:HitEvent = HitEvent.new()
		hitevent.damage = max(1,damage)
		
		var bodies = self.get_overlapping_bodies()
		
		for body in bodies:
			if body.has_method("hit"):
				
				body.hit(hitevent)
		
		if duration == 0:
			$AnimationPlayer.play("fade_out")
			return
		print("POOPY")
		await get_tree().create_timer(0.5).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $AnimationPlayer.is_playing():
		self.modulate.a -= 1*delta
	pass
