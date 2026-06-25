
varying vec3 v_vNormal;
varying vec4 v_vColour;
varying float v_vAO;

uniform vec3 u_light_ambient;
uniform vec3 u_light_dir;
uniform vec3 u_light_col;
uniform float u_ao_value;

void main() {
	
    vec4 fragcol    = v_vColour;
    vec3 normal     = normalize(v_vNormal);
	float light_fac	= 0.5; // ambient
	
	// Lambert light
	//vec3 light_dir  = normalize(vec3(1, 1, 0));
	//light_fac       = dot(light_dir, -normal);//*0.5+0.5;
	
	// Minecraft-like light
	light_fac += 0.1 * abs(normal.x);
	light_fac += 0.3 * abs(normal.y);
	light_fac += max(0.0, -normal.z);
	light_fac = clamp(light_fac, 0.0, 1.0);
    
    // Vertex AO
    float ao_fac = mix(0.6, 1.0, v_vAO);
    fragcol.rgb *= ao_fac * light_fac;

    gl_FragColor = fragcol;
    //gl_FragColor = vec4(-normal*0.5+0.5, 1.0);
}
