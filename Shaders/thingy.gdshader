shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float fadeWidth;
uniform float randRes;
uniform float baseAdd;

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123 );
}

void fragment() {
		vec2 center = vec2(0.5,0.5);
        vec4 color = texture(screen_texture, SCREEN_UV, 0.0);
		float circSize = fadeWidth;
		float dist = distance (UV, center);
		vec4 finalColor = color;


		float transition = smoothstep(circSize, 0.0, dist) ;
		finalColor = mix( vec4(0,0,0,190.0 + (sin(TIME) * 25.0) ), color, (transition + (random(UV) - 0.5)/(randRes + (sin(TIME) * 10.0)) ));

		COLOR = finalColor;

}