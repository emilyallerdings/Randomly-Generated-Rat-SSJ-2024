extends Node

var main_scene
var difficulty = 0
var minimap = null
var floor_num = 1


var descriptions = [[],[], []]
var titles = [[],[], []]

const charged_title = "Charged Spit Accelerator"
const charged_desc = "     Single lightning infused shots. Fast but small.
					\n     High base damage."

const rocket_title = "Rocket Barf"
const rocket_desc = "     Spray with high knocback. You become a projectile.
					\n     Short invincibility during knockback."
	
const spray_title = "Acid Spray"
const spray_desc = "     Powerful blast of acid.
					\n     Number of shots scales with damage."		
					
					
const belch_title = "Belch Bubble"
const belch_desc = "     Your acid coagulates into slow but large bubbles.
					\n     Leaves an acid puddle when popped."

const combust_title = "Internal Combustion Guts"
const combust_desc = "     Your acid is highly condensed and highly corrosive.
					\n     Increased damage and speed."

const webbed_title = "Webbed Feet"
const feet_webbed_desc = "     Webbed feet allow for greater stability.
					\n     Reduces Knockback. Increases Traction"

const reverse_title = "Thruster Feet"
const reverse_feet_desc = "     Throw yourself into battle!.
					\n     Knockback is reversed. Physics broken."

const acid_title = "Acid Stored In The Legs"
const feet_acid_desc = "     Your legs help produce more dangerous acid.
					\n     Shot damage increased. Shot charge increased."

# Called when the node enters the scene tree for the first time.
func _ready():
	
	descriptions[0].append(charged_desc)
	descriptions[0].append(rocket_desc)
	descriptions[0].append(spray_desc)
	
	titles[0].append(charged_title)
	titles[0].append(rocket_title)
	titles[0].append(spray_title)
	
	descriptions[1].append(belch_desc)
	descriptions[1].append(combust_desc)

	titles[1].append(belch_title)
	titles[1].append(combust_title)

	descriptions[2].append(feet_webbed_desc)
	descriptions[2].append(reverse_feet_desc)
	descriptions[2].append(feet_acid_desc)
	
	titles[2].append(webbed_title)
	titles[2].append(reverse_title)
	titles[2].append(acid_title)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_child_to_main(child):
	main_scene.add_child(child)
