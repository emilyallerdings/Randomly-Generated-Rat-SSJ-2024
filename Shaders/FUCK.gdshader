shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = vec4(0,0,0,1);
	// Called for every pixel the material is visible on.
}
void light() {
	LIGHT = vec4(0,0,0,0);
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
}
