#version 120

uniform int active_lights_n; // Number of active lights (< MG_MAX_LIGHT)
uniform vec3 scene_ambient; // Scene ambient light

struct material_t {
	vec3  diffuse;
	vec3  specular;
	float alpha;
	float shininess;
};

struct light_t {
	vec4 position;    // Camera space
	vec3 diffuse;     // rgb
	vec3 specular;    // rgb
	vec3 attenuation; // (constant, lineal, quadratic)
	vec3 spotDir;     // Camera space
	float cosCutOff;  // cutOff cosine
	float exponent;
};

uniform light_t theLights[4];
uniform material_t theMaterial;

uniform sampler2D texture0;
uniform sampler2D bumpmap;

varying vec2 f_texCoord;
varying vec3 f_viewDirection;     // tangent space
varying vec3 f_lightDirection[4]; // tangent space
varying vec3 f_spotDirection[4];  // tangent space

vec3 espekularra(vec3 n, vec3 l, float nl,light_t theLight){
	vec3 v = f_viewDirection;
	v = normalize(v);
	vec3 r = 2 * nl * n - l;
	r = normalize(r);
	float rv = dot(r, v);
	float smax = pow(max(0, rv), theMaterial.shininess);
	
	return smax * (theMaterial.specular * theLight.specular);
}

vec3 direkzionala(light_t theLight, vec3 n, int i){
	vec3 l = f_lightDirection[i];
	l = normalize(l);

	float nl = dot(l, n);
	float dmax = max(0,nl);
	vec3 idif = theLight.diffuse * theMaterial.diffuse;

	vec3 ispec = espekularra(n, l, nl, theLight);

	return dmax * (idif + ispec);
}

vec3 lokala(light_t theLight, vec3 n, int i){
	vec3 l = f_lightDirection[i];
	l = normalize(l);

	float nl = dot(n, l);
	float lmax = max(nl,0);
	vec3 idif = (theLight.diffuse * theMaterial.diffuse);
	vec3 ispec = espekularra(n, l, nl, theLight);

	return lmax *(idif + ispec);
}

vec3 spotlight(light_t theLight, vec3 n, int i){
	vec3 l = f_lightDirection[i];
	l = normalize(l);
	float nl = dot(n,l);

	float ls = dot(-l, f_spotDirection[i]);

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
	//Base color
	vec4 baseColor = texture2D(texture0, f_texCoord);

	//Decode the tangent space  normal (from [0...1] to [-1...+1])
	vec3 N = texture2D(bumpmap, f_texCoord).rgb * 2.0 - 1.0;
	N = normalize(N);

	vec3 batura = vec3(0);
	for(int i = 0; i < active_lights_n; i++){
		if(theLights[i].position.w == 0){
			batura = batura + direkzionala(theLights[i], N, i);
		}else{
			if(theLights[i].cosCutOff == 0){
				batura = batura + lokala(theLights[i], N, i);
			}else{
				batura = batura + spotlight(theLights[i], N, i);
			}
		}
	}
	vec4 f_color = vec4(batura + scene_ambient, 1);

	gl_FragColor = f_color * baseColor;
}
