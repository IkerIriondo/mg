#version 120

uniform int active_lights_n; // Number of active lights (< MG_MAX_LIGHT)
uniform vec3 scene_ambient; // Scene ambient light

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

uniform sampler2D texture0;

varying vec3 f_position;      // camera space
varying vec3 f_viewDirection; // camera space
varying vec3 f_normal;        // camera space
varying vec2 f_texCoord;

vec3 espekularra(vec3 n, vec3 l, float nl,light_t theLight){
	vec3 v = -f_position;
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
	vec3 n = f_normal;
	n = normalize(n);
	float nl = dot(l, n);
	float dmax = max(0,nl);
	vec3 idif = theLight.diffuse * theMaterial.diffuse;

	vec3 ispec = espekularra(n, l, nl, theLight);

	return dmax * (idif + ispec);
}

vec3 lokala(light_t theLight){
	float dist = distance(theLight.position, vec4(f_position, 1));
	vec3 n = f_normal;
	n = normalize(n);
	vec3 l = vec4(theLight.position - vec4(f_position, 1)).xyz;
	l = normalize(l);
	float nl = dot(n, l);
	float lmax = max(nl,0);
	vec3 idif = (theLight.diffuse * theMaterial.diffuse);
	vec3 ispec = espekularra(n, l, nl, theLight);

	return lmax *(idif + ispec);
}

vec3 spotlight(light_t theLight){
	vec3 l = vec4(theLight.position - vec4(f_position, 1)).xyz;
	l = normalize(l);
	vec3 n = f_normal;
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
	vec4 f_color = vec4(batura + scene_ambient, 1);
	vec4 tcolor = texture2D(texture0, f_texCoord);
	gl_FragColor = vec4(f_color) *tcolor;

}
