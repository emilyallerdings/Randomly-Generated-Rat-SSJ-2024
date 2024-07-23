extends DeathEffect
class_name SpawnerEffect

@export var node_to_spawn:PackedScene = null

func on_trigger(node):
	if node_to_spawn:
		var new_spawn = node_to_spawn.instantiate()
		if new_spawn.has_method("set_creator"):
			new_spawn.set_creator(node)
		new_spawn.global_position = node.global_position + node.velocity.normalized()*32
		node.get_parent().add_child(new_spawn)
	return
