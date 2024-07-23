extends Camera2D

var player = null

func _physics_process(delta):
	if player.in_menu:
		return
	var mouse_pos = get_global_mouse_position()
	
	offset.x = snapped((mouse_pos.x - global_position.x) / (1920.0 / 2.0) * 260, 0.5)
	offset.y = snapped((mouse_pos.y - global_position.y) / (1080.0 / 2.0) * 260, 0.5)
	
	self.global_position = snapped(player.global_position, Vector2(0.5,0.5))
	
	force_update_scroll()
