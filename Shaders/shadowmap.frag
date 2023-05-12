#version 120

varying vec4 f_color;
varying vec2 f_texCoord;

uniform sampler2D texture0;

//Itzalak

uniform sampler2D ts;
varying vec4 fc;

void main() {
	vec4 tcolor = texture2D(texture0, f_texCoord);
	gl_FragColor = vec4(f_color) * tcolor;
}