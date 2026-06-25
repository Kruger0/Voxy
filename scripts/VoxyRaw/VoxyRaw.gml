
/// @ignore
function VoxyRawGetPixel(buffer, x, y, z, width, height, number) {
    if (x < 0 || x >= width ||
        y < 0 || y >= height ||
        z < 0 || z >= number) {
        return 0;
    }
    var _offset = (x + y * width + z * width * height) * 4;
    var _peek = buffer_peek(buffer, _offset, buffer_u32);
    return (_peek >> 24) & 0xFF;
}

/// @ignore
function VoxyRawCreate(sprite, frame, width, heigth, xOff, yOff, number) {
    var _all = (frame == -1);
    var _frameCount = _all ? number : 1;
    var _frameSize = width * heigth * 4;
    var _buff = buffer_create(_frameSize * _frameCount, buffer_fixed, 1);
    var _surf = surface_create(width, heigth);
    surface_set_target(_surf);
    for (var i = 0; i < _frameCount; i++) {
        draw_clear_alpha(c_black, 0);
        draw_sprite(sprite, _all ? i : frame, xOff, yOff);
        buffer_get_surface(_buff, _surf, _frameSize * i);
    }
    surface_reset_target();
    surface_free(_surf);
    buffer_seek(_buff, buffer_seek_start, 0);
    return _buff;
}

/// @ignore
function VoxyRawSolidify(buffer, width, height, xOff, yOff, zOff, number, shaded) {
    static __data = VoxyInit();
    static _offsets = [
        [ 1, 0, 0], [ 0, 1, 0], [ 0, 0, 1],
        [-1, 0, 0], [ 0,-1, 0], [ 0, 0,-1],
    ];
    static _faces = [
        [0, 1, 0, 0, [1,0,0],[1,1,0],[1,1,1],[1,0,1]],
        [1, 0, 1, 0, [0,1,0],[0,1,1],[1,1,1],[1,1,0]],
        [2, 0, 0, 1, [0,0,1],[1,0,1],[1,1,1],[0,1,1]],
        [3,-1, 0, 0, [0,0,0],[0,0,1],[0,1,1],[0,1,0]],
        [4, 0,-1, 0, [0,0,0],[1,0,0],[1,0,1],[0,0,1]],
        [5, 0, 0,-1, [0,0,0],[0,1,0],[1,1,0],[1,0,0]],
    ];
    var _area = width * height;
    var _vbuff = vertex_create_buffer();
    var _neig = array_create(6, false);
    vertex_begin(_vbuff, __data.format);
    for (var i = 0; i < _area * number; i++) {
        var _pixel = buffer_read(buffer, buffer_u32);
        var _color = _pixel & 0xFFFFFF;
        var _a = (_pixel >> 24) & 0xFF;
        if (_a <= 0) continue;
        var _x = (i mod width);
        var _y = (i div width) mod height;
        var _z = (i div _area) mod number;
        for (var n = 0; n < 6; n++) {
            var _nx = _x + _offsets[n][0];
            var _ny = _y + _offsets[n][1];
            var _nz = _z + _offsets[n][2];
            _neig[n] = VoxyRawGetPixel(buffer, _nx, _ny, _nz, width, height, number) > 0;
        }
        if (_neig[0] && _neig[1] && _neig[2] && _neig[3] && _neig[4] && _neig[5]) continue;
        var _px = _x - xOff;
        var _py = _y - yOff;
        var _pz = _z - zOff;
        for (var f = 0; f < 6; f++) {
            var _f = _faces[f];
            if (_neig[_f[0]]) continue;
            var _brightness = shaded ? __data.brightness[f] : 1.0;
            var _r = (_color & 0xFF) * _brightness;
            var _g = ((_color >> 8) & 0xFF) * _brightness;
            var _b = ((_color >> 16) & 0xFF) * _brightness;
            var _blend = make_color_rgb(_r, _g, _b);
            VoxyVertexAdd(_vbuff, _px+_f[4][0], _py+_f[4][1], _pz+_f[4][2], _f[1], _f[2], _f[3], _blend, _a, 0, 0);
            VoxyVertexAdd(_vbuff, _px+_f[5][0], _py+_f[5][1], _pz+_f[5][2], _f[1], _f[2], _f[3], _blend, _a, 0, 0);
            VoxyVertexAdd(_vbuff, _px+_f[6][0], _py+_f[6][1], _pz+_f[6][2], _f[1], _f[2], _f[3], _blend, _a, 0, 0);
            VoxyVertexAdd(_vbuff, _px+_f[6][0], _py+_f[6][1], _pz+_f[6][2], _f[1], _f[2], _f[3], _blend, _a, 0, 0);
            VoxyVertexAdd(_vbuff, _px+_f[7][0], _py+_f[7][1], _pz+_f[7][2], _f[1], _f[2], _f[3], _blend, _a, 0, 0);
            VoxyVertexAdd(_vbuff, _px+_f[4][0], _py+_f[4][1], _pz+_f[4][2], _f[1], _f[2], _f[3], _blend, _a, 0, 0);
        }
    }
    vertex_end(_vbuff);
    vertex_freeze(_vbuff);
    buffer_delete(buffer);
    return _vbuff;
}
