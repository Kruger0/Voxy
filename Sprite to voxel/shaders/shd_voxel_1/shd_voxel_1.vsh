
attribute vec3 in_Position; // x  |  y  |  z  
attribute vec4 in_Colour0;  // r  |  g  |  b  | a
attribute vec4 in_Colour1;  // nx | ny  | nz  | ssao

uniform mat4 u_inv_mat;

varying vec4 v_vColour;
varying vec3 v_vNormal;
varying float v_vAO;

void main() {
    vec4 object_space_pos = vec4(in_Position, 1.0);
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
    
    vec3 Normal = in_Colour1.xyz*2.0-1.0;
    
    v_vColour   = in_Colour0;
    v_vNormal   = Normal;
    //v_vNormal   = vec4(u_inv_mat * vec4(-Normal, 0.0)).xyz;
    //v_vNormal   = normalize(mat3(gm_Matrices[MATRIX_WORLD]) * Normal);
    v_vAO       = in_Colour1.w;
}
