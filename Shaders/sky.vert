#version 120

uniform mat4 modelToCameraMatrix;
uniform mat4 cameraToClipMatrix;
uniform mat4 modelToWorldMatrix;
uniform mat4 modelToClipMatrix;

attribute vec3 v_position;

varying vec3 f_texCoord; // Note: texture coordinates is vec3

void main() {
	f_texCoord = v_position;
	gl_Position = modelToClipMatrix * vec4(v_position, 1.0);
}
