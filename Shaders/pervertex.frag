#version 120

varying vec4 f_color;
varying vec2 f_texCoord;

uniform sampler2D texture0;

// To sample a texel from a texture, use "texture2D" function:
//
// vec4 texture2D(sampler2D sampler, vec2 coord);

void main() {
	vec4 tcolor = texture2D(texture0, f_texCoord);
	gl_FragColor = vec4(f_color) * tcolor;
}
