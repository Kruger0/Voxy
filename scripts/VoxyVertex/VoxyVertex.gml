
/// @ignore
function VoxyVertexAdd(vbuff, x, y, z, nx, ny, nz, col, alpha, u, v) {
    static __data = VoxyInit();
    static __vertex = array_create(4);
    matrix_transform_vertex(__data.matrix, x, y, z, 1, __vertex);
    vertex_position_3d(vbuff, __vertex[0], __vertex[1], __vertex[2]);
    vertex_normal(vbuff, nx, ny, nz);
    vertex_color(vbuff, col, alpha);
    vertex_texcoord(vbuff, u, v);
}
