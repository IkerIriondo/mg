#version 120

uniform mat4 modelToCameraMatrix;
uniform mat4 cameraToClipMatrix;
uniform mat4 modelToWorldMatrix;
uniform mat4 modelToClipMatrix;

uniform int active_lights_n; // Number of active lights (< MG_MAX_LIGHT)
uniform vec3 scene_ambient;  // rgb

uniform struct light_t {
	vec4 position;    // Camera space
	vec3 diffuse;     // rgb
	vec3 specular;    // rgb
	vec3 attenuation; // (constant, lineal, quadratic)
	vec3 spotDir;     // Camera space
	float cosCutOff;  // cutOff cosine
	float exponent;
} theLights[4];     // MG_MAX_LIGHTS

uniform struct material_t {
	vec3  diffuse;
	vec3  specular;
	float alpha;
	float shininess;
} theMaterial;

attribute vec3 v_position; // Model space
attribute vec3 v_normal;   // Model space
attribute vec2 v_texCoord;

varying vec4 f_color;
varying vec2 f_texCoord;

void main() {
	gl_Position = modelToClipMatrix * vec4(v_position, 1);
	vec3 l = -theLights[0].position.xyz;
	l = normalize(l);
	vec3 n = vec4(modelToCameraMatrix * vec4(v_normal,0)).xyz;
	n = normalize(n);
	float nl = dot(l, n);
	float max = max(0,nl);
	vec3 idif = theLights[0].diffuse * theMaterial.diffuse;
	vec3 r = 2 * nl * n - l;
	vec3 v = vec3(modelToCameraMatrix[3][0] - v_position.x, modelToCameraMatrix[3][1] - v_position.y, modelToCameraMatrix[3][2] - v_position.z);
	v = normalize(v);
	float rv = dot(r,v);
	

	vec3 ispec = 

	f_color = vec4(scene_ambient + max * (idif + ispec,1);
}
