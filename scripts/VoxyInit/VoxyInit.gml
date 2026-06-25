
/// @ignore
function VoxyInit() {
    static data = undefined
    if (is_undefined(data)) {
        data = {};
        with (data) {
            models = {};
            format = -1;
            matrix = matrix_build_identity();
            brightness = [0.6, 0.8, 1.0, 0.6, 0.8, 0.5];
        }
    }
    return data;
}

vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_color();
vertex_format_add_texcoord();
VoxyInit().format = vertex_format_end();
