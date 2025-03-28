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
	vec4 position = vec4(modelToCameraMatrix * vec4(v_position,1));
	vec3 v = -position.xyz;
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
	vec4 position = vec4(modelToCameraMatrix * vec4(v_position,1));
	float dist = distance(theLight.position, position);
	float d = 1/(theLight.attenuation.x + theLight.attenuation.y * dist + theLight.attenuation.z * pow(dist, 2));
	vec3 n = vec4(modelToCameraMatrix * vec4(v_normal,0)).xyz;
	n = normalize(n);
	vec3 l = vec4(theLight.position - position).xyz;
	l = normalize(l);
	float nl = dot(n, l);
	float lmax = max(nl,0);
	vec3 idif = (theLight.diffuse * theMaterial.diffuse);
	vec3 ispec = espekularra(n, l, nl, theLight);

	return d * lmax *(idif + ispec);
}

vec3 spotlight(light_t theLight){
	vec4 position = vec4(modelToCameraMatrix * vec4(v_position,1));

	vec3 l = vec4(theLight.position - position).xyz;
	l = normalize(l);
	vec3 n = vec4(modelToCameraMatrix * vec4(v_normal,0)).xyz;
	n = normalize(n);
	float nl = dot(n,l);


	float ls = dot(-l, theLight.spotDir);

	float cspot = max(ls, 0);

	if(cspot < theLight.cosCutOff){
		return vec3(0);
	}else{
		vec3 idif = (theLight.diffuse * theMaterial.diffuse);
		vec3 ispec = espekularra(n, l, nl, theLight);

		return cspot * max(nl,0) * (idif + ispec);
	}

}

void main() {
	gl_Position = modelToClipMatrix * vec4(v_position, 1);

	vec3 batura = vec3(0);
	for(int i = 0; i < active_lights_n; i++){
		if(theLights[i].position.w == 0){
			batura = batura + direkzionala(theLights[i]);
		}else{
			if(theLights[i].cosCutOff == 0){
				batura = batura + lokala(theLights[i]);
			}else{
				batura = batura + spotlight(theLights[i]);
			}
		}
	}
	f_texCoord = v_texCoord;
	f_color = vec4(scene_ambient + batura,1);
}
