
varying vec3 v_vNormal;
varying vec4 v_vColour;

float remap(float value, float fromMin, float fromMax, float toMin, float toMax) {
    return toMin + (value - fromMin) * (toMax - toMin) / (fromMax - fromMin);
}

void main() {
	
	vec3 light_ambient	= vec3(0.0);		// Ambient light
	float light_min		= 0.4;				// Minimum light value
	
	// Lambert light
	//vec3 light_dir		= vec3(-0.6, -0.8, -1);	// Light direction	
	//float NdotL			= dot(v_vNormal, normalize(light_dir));
	//NdotL				= remap(NdotL, -1.0, 1.0, light_min, 1.0);
	
	// Minecraft-like light
	float NdotL = light_min;
	NdotL += 0.2 * abs(v_vNormal.x);
	NdotL += 0.4 * abs(v_vNormal.y);
	NdotL += (1.0-light_min) * step(0.001, -v_vNormal.z);
	
	vec3 final_col		= mix(light_ambient, v_vColour.rgb, NdotL);
						
    gl_FragColor		= vec4(final_col, 1.0);
}
