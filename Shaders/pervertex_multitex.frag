#version 120

varying vec4 f_color;
varying vec2 f_texCoord;

uniform sampler2D texture0;
uniform sampler2D texture1;

uniform float uCloudOffset; // The offset of the cloud texture

void main() {

	// The final color must be a linear combination of both
	// textures with a factor of 0.5, e.g:
	//
	// color = 0.5 * color_of_texture0 + 0.5 * color_of_texture1
	vec4 color_of_texture0 = texture2D(texture0, f_texCoord);
	vec4 color_of_texture1 = texture2D(texture1, vec2(f_texCoord.x + uCloudOffset, f_texCoord.y));
	vec4 tcolor = 0.5 * color_of_texture0 + 0.5 * color_of_texture1;
	gl_FragColor = vec4(f_color) * tcolor;
}
