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

vec3 espekularra(vec3 n, vec3 l, float nl,light_t theLight){
	vec3 v = gl_Position.xyz;
	v = normalize(v);
	vec3 r = 2 * nl * n - l;
	r = normalize(r);
	float rv = dot(r, v);
	float smax = pow(max(0, rv), theMaterial.shininess);
	
	return smax * (theMaterial.specular * theLight.specular);
}

vec3 direkzionala(light_t theLight){
	vec3 l = -theLight.position.xyz;
	l = normalize(l);
	vec3 n = vec4(modelToCameraMatrix * vec4(v_normal,0)).xyz;
	n = normalize(n);
	float nl = dot(l, n);
	float dmax = max(0,nl);
	vec3 idif = theLight.diffuse * theMaterial.diffuse;

	vec3 ispec = espekularra(n, l, nl, theLight);

	return dmax * (idif + ispec);
}

vec3 lokala(light_t theLight){
	vec3 n = vec4(modelToCameraMatrix * vec4(v_normal,0)).xyz;
	n = normalize(n);
	vec3 l = vec4(theLight.position - gl_Position).xyz;
	l = normalize(l);
	float nl = dot(n, l);
	
	vec3 idif = theLight.diffuse * theMaterial.diffuse;
	vec3 ispec = espekularra(n, l, nl, theLight);

	return idif + ispec;
}

void main() {
	gl_Position = modelToClipMatrix * vec4(v_position, 1);
	
	f_color = vec4(scene_ambient + lokala(theLights[0]),1);
}
