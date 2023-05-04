#version 120

// Bump mapping with many lights.

// all attributes in model space
attribute vec3 v_position;
attribute vec3 v_normal;
attribute vec2 v_texCoord;
attribute vec3 v_TBN_t;
attribute vec3 v_TBN_b;

uniform mat4 modelToCameraMatrix;
uniform mat4 modelToWorldMatrix;
uniform mat4 cameraToClipMatrix;
uniform mat4 modelToClipMatrix;

uniform int active_lights_n; // Number of active lights (< MG_MAX_LIGHT)

uniform struct light_t {
	vec4 position;    // Camera space
	vec3 diffuse;     // rgb
	vec3 specular;    // rgb
	vec3 attenuation; // (constant, lineal, quadratic)
	vec3 spotDir;     // Camera space
	float cosCutOff;  // cutOff cosine
	float exponent;
} theLights[4];     // MG_MAX_LIGHTS

// All bump computations are performed in tangent space; therefore, we need to
// convert all light (and spot) directions and view directions to tangent space
// and pass them the fragment shader.

varying vec2 f_texCoord;
varying vec3 f_viewDirection;     // tangent space
varying vec3 f_lightDirection[4]; // tangent space
varying vec3 f_spotDirection[4];  // tangent space

void main() {

	//3x3 modelview matrizea lortu
	mat3 MV3x3 = mat3(modelToCameraMatrix);

	//tangentea, bitangentea eta normala kamera koordenatuetara pasa
	//object space -> camera space
	vec3 t = MV3x3 * v_TBN_t;
	vec3 b = MV3x3 * v_TBN_b;
	vec3 n = MV3x3 * v_normal;

	//kamera espaziotik, tangente espaziora bihurtzen duen matrizea
	mat3 cameraToTangent = mat3(t, b, n);

	//argiaren norabidea tangente espaziora pasa
	//camera space -> tangent space
	vec4 position = vec4(modelToCameraMatrix * vec4(v_position,1));
	f_viewDirection = cameraToTangent * -position.xyz;
	
	for(int i = 0; i < 4; i++){
		if(theLights[i].position.w == 0){
			f_lightDirection[i] = cameraToTangent * -theLights[i].position.xyz;
		}else{
			f_lightDirection[i] = cameraToTangent * vec4(theLights[i].position - position).xyz;
		}
		f_spotDirection[i] = cameraToTangent * theLights[i].spotDir;
	}
	f_texCoord = v_texCoord;

	gl_Position = modelToClipMatrix * vec4(v_position, 1.0);
}
