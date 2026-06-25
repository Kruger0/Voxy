
///@ignore
function __VoxelCache() {
    static data = {
        models  : {},
    }
    return data;
}
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_color();
vertex_format_add_color();
__VoxelCache().vform = vertex_format_end();

///@ignore
function __VoxelGet(name) {
    return __VoxelCache().models[$ name];
}

///@ignore
function __VertexAdd(vb, px, py, pz, col, alpha, nx, ny, nz, ao, mat) {
    if (mat) {
        var _p = matrix_transform_vertex(mat, px, py, pz);
        var _n = matrix_transform_vertex(mat, nx, ny, nz, 0);
        var _px = _p[0];
        var _py = _p[1];
        var _pz = _p[2];
        var _nx = (_n[0]*0.5+0.5) * 255;
        var _ny = (_n[1]*0.5+0.5) * 255;
        var _nz = (_n[2]*0.5+0.5) * 255;
    } else {
        var _px = px;
        var _py = py;
        var _pz = pz;
        var _nx = (nx*0.5+0.5) * 255;
        var _ny = (ny*0.5+0.5) * 255;
        var _nz = (nz*0.5+0.5) * 255; 
    }
    var _ao = round((ao / 3) * 255)
    vertex_position_3d(vb, _px, _py, _pz);
    vertex_color(vb, col, alpha);
    vertex_argb(vb, (_ao << 24) | (_nz << 16) | (_ny << 8) | (_nx));
}

///@ignore
function __PosToIndex(wid, hei, x, y, z) {
	return x + y * wid + z * wid * hei;
}	

///@ignore
function __GetPixel(buffer, w, h, d, x, y, z) {
    if (x < 0 || x >= w ||
        y < 0 || y >= h ||
        z < 0 || z >= d) {
        return 0;
    }

    var _offset = (x + y * w + z * w * h) * buffer_sizeof(buffer_u32);
    var _peek = buffer_peek(buffer, _offset, buffer_u32)
    return (_peek >> 24) & 0xFF
}

///@ignore
function __VertexAO(side1, side2, corner) {
    var _result = 0
    if(side1 && side2) {
        _result = 0;
    } else {
        _result = 3 - (side1 + side2 + corner);
    }
    return _result
}

///@ignore
function __VoxelCreate(sprite, fromBottom, zAlign, ambientOcclusion = true, modelMatrix = -1) {
    
    // Sprite info
    var _wid		= sprite_get_width(sprite);
    var _hei		= sprite_get_height(sprite);
    var _frames		= sprite_get_number(sprite);
    var _spr_xoff	= sprite_get_xoffset(sprite);
    var _spr_yoff	= sprite_get_yoffset(sprite);

    // Convert into a buffer
    var _size		= buffer_sizeof(buffer_u32);
    var _frame_size	= _wid * _hei * _size;
    var _buff_size	= _frame_size * _frames;
    var _buff		= buffer_create(_buff_size, buffer_fixed, 1);
    var _surf		= surface_create(_wid, _hei);
    
    for (var _i = 0; _i < _frames; _i++) {
        surface_set_target(_surf);
            draw_clear_alpha(c_black, 0);
            var _frame = abs(((fromBottom * _frames) - fromBottom) - _i)
            draw_sprite(sprite, _frame, _spr_xoff, _spr_yoff);
        surface_reset_target();
        buffer_get_surface(_buff, _surf, _frame_size * _i);
    }
    surface_free(_surf);
    buffer_seek(_buff, buffer_seek_start, 0);	

    // Generate model
    var _vbuff = vertex_create_buffer();	
	vertex_begin(_vbuff, __VoxelCache().vform);
    
    var _neig_00, _neig_01, _neig_02, _neig_03, _neig_04, _neig_05
    var _neig_06, _neig_07, _neig_08, _neig_09, _neig_10, _neig_11, _neig_12, _neig_13
    var _neig_14 ,_neig_15, _neig_16, _neig_17
    var _neig_18, _neig_19, _neig_20, _neig_21, _neig_22, _neig_23, _neig_24, _neig_25
    
    var _ao_v0, _ao_v1, _ao_v2, _ao_v3 ,_ao_v4 ,_ao_v5 ,_ao_v6 ,_ao_v7
    
    for (var _i = 0; _i < _wid * _hei * _frames; _i++) {
        var _pixel	= buffer_read(_buff, buffer_u32);
        var _color	= _pixel & 0xFFFFFF;
        var _alpha	= (_pixel >> 24) & 0xFF;
        if (_alpha <= 0.0) continue;
        
        var _x	= (_i mod _wid);
        var _y	= (_i div _wid) mod _hei;
        var _z	= (_i div (_wid * _hei)) mod _frames;

        #region Get neighbors
        
        // Sides
        _neig_00 = __GetPixel(_buff, _wid, _hei, _frames, _x+1, _y, _z) > 0
        _neig_01 = __GetPixel(_buff, _wid, _hei, _frames, _x, _y+1, _z) > 0
        _neig_02 = __GetPixel(_buff, _wid, _hei, _frames, _x, _y, _z+1) > 0
        _neig_03 = __GetPixel(_buff, _wid, _hei, _frames, _x-1, _y, _z) > 0
        _neig_04 = __GetPixel(_buff, _wid, _hei, _frames, _x, _y-1, _z) > 0
        _neig_05 = __GetPixel(_buff, _wid, _hei, _frames, _x, _y, _z-1) > 0
        
        // If its fully occluded, skip
        if (_neig_00 && _neig_01 && _neig_02 && _neig_03 && _neig_04 && _neig_05) continue;
        
        // Corners
        _neig_06 = __GetPixel(_buff, _wid, _hei, _frames, _x-1, _y+1, _z-1) > 0
        _neig_07 = __GetPixel(_buff, _wid, _hei, _frames, _x,   _y+1, _z-1) > 0
        _neig_08 = __GetPixel(_buff, _wid, _hei, _frames, _x+1, _y+1, _z-1) > 0
        _neig_09 = __GetPixel(_buff, _wid, _hei, _frames, _x-1, _y,   _z-1) > 0
        _neig_10 = __GetPixel(_buff, _wid, _hei, _frames, _x+1, _y,   _z-1) > 0
        _neig_11 = __GetPixel(_buff, _wid, _hei, _frames, _x-1, _y-1, _z-1) > 0
        _neig_12 = __GetPixel(_buff, _wid, _hei, _frames, _x  , _y-1, _z-1) > 0
        _neig_13 = __GetPixel(_buff, _wid, _hei, _frames, _x+1, _y-1, _z-1) > 0
        _neig_14 = __GetPixel(_buff, _wid, _hei, _frames, _x-1, _y+1, _z  ) > 0
        _neig_15 = __GetPixel(_buff, _wid, _hei, _frames, _x+1, _y+1, _z  ) > 0
        _neig_16 = __GetPixel(_buff, _wid, _hei, _frames, _x-1, _y-1, _z  ) > 0
        _neig_17 = __GetPixel(_buff, _wid, _hei, _frames, _x+1, _y-1, _z  ) > 0
        _neig_18 = __GetPixel(_buff, _wid, _hei, _frames, _x-1, _y+1, _z+1) > 0
        _neig_19 = __GetPixel(_buff, _wid, _hei, _frames, _x,   _y+1, _z+1) > 0
        _neig_20 = __GetPixel(_buff, _wid, _hei, _frames, _x+1, _y+1, _z+1) > 0
        _neig_21 = __GetPixel(_buff, _wid, _hei, _frames, _x-1, _y,   _z+1) > 0
        _neig_22 = __GetPixel(_buff, _wid, _hei, _frames, _x+1, _y,   _z+1) > 0
        _neig_23 = __GetPixel(_buff, _wid, _hei, _frames, _x-1, _y-1, _z+1) > 0
        _neig_24 = __GetPixel(_buff, _wid, _hei, _frames, _x  , _y-1, _z+1) > 0
        _neig_25 = __GetPixel(_buff, _wid, _hei, _frames, _x+1, _y-1, _z+1) > 0
        
        #endregion
        
        /*
        Bottom -Z       Middle Z        Top +Z
        11  12  13      16  04  17      23  24  25      -Y
        09  05  10      03      00      21  02  22    -X  +X
        06  07  08      14  01  15      18  19  20      +Y
        
        v0      v1                      v4      v5  

        v2      v3                      v6      v7        
        */
        
        _x -= _spr_xoff;
		_y -= _spr_yoff;
		_z -= _frames*zAlign;
        
        if !(_neig_00) { // +X            
            _ao_v5 = __VertexAO(_neig_22, _neig_17, _neig_25)
            _ao_v7 = __VertexAO(_neig_22, _neig_15, _neig_20)
            _ao_v1 = __VertexAO(_neig_10, _neig_17, _neig_13)
            _ao_v3 = __VertexAO(_neig_10, _neig_15, _neig_08)
            if (_ao_v7 + _ao_v1 > _ao_v3 + _ao_v5) {
                __VertexAdd(_vbuff,	_x+1,	_y,		_z,		_color, _alpha, 1, 0, 0, _ao_v1);
                __VertexAdd(_vbuff,	_x+1,	_y,		_z+1,	_color, _alpha, 1, 0, 0, _ao_v5);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z+1,	_color, _alpha, 1, 0, 0, _ao_v7);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z+1,	_color, _alpha, 1, 0, 0, _ao_v7);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z,		_color, _alpha, 1, 0, 0, _ao_v3); 
                __VertexAdd(_vbuff,	_x+1,	_y,		_z,		_color, _alpha, 1, 0, 0, _ao_v1);
            } else {                
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z,		_color, _alpha, 1, 0, 0, _ao_v3);
                __VertexAdd(_vbuff,	_x+1,	_y,		_z,		_color, _alpha, 1, 0, 0, _ao_v1);
                __VertexAdd(_vbuff,	_x+1,	_y,		_z+1,	_color, _alpha, 1, 0, 0, _ao_v5);
                __VertexAdd(_vbuff,	_x+1,	_y,		_z+1,	_color, _alpha, 1, 0, 0, _ao_v5);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z+1,	_color, _alpha, 1, 0, 0, _ao_v7);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z,		_color, _alpha, 1, 0, 0, _ao_v3);
            }
        }
        if !(_neig_01) { // +Y
            _ao_v6 = __VertexAO(_neig_19, _neig_14, _neig_18)
            _ao_v7 = __VertexAO(_neig_19, _neig_15, _neig_20)
            _ao_v2 = __VertexAO(_neig_07, _neig_14, _neig_06)
            _ao_v3 = __VertexAO(_neig_07, _neig_15, _neig_08)
            if (_ao_v7 + _ao_v2 > _ao_v6 + _ao_v3) {
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z+1,	_color, _alpha, 0, 1, 0, _ao_v7);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z+1,	_color, _alpha, 0, 1, 0, _ao_v6);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z,		_color, _alpha, 0, 1, 0, _ao_v2);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z,		_color, _alpha, 0, 1, 0, _ao_v2);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z,		_color, _alpha, 0, 1, 0, _ao_v3);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z+1,	_color, _alpha, 0, 1, 0, _ao_v7);
            } else {
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z,		_color, _alpha, 0, 1, 0, _ao_v3);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z+1,	_color, _alpha, 0, 1, 0, _ao_v7);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z+1,	_color, _alpha, 0, 1, 0, _ao_v6);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z+1,	_color, _alpha, 0, 1, 0, _ao_v6);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z,		_color, _alpha, 0, 1, 0, _ao_v2);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z,		_color, _alpha, 0, 1, 0, _ao_v3);
            }
        }
        if !(_neig_02) { // +Z
            _ao_v4 = __VertexAO(_neig_24, _neig_21, _neig_23);
            _ao_v5 = __VertexAO(_neig_24, _neig_22, _neig_25);
            _ao_v6 = __VertexAO(_neig_19, _neig_21, _neig_18);
            _ao_v7 = __VertexAO(_neig_19, _neig_22, _neig_20);
            if (_ao_v4 + _ao_v7 > _ao_v6 + _ao_v5) {
                __VertexAdd(_vbuff,	_x,		_y,		_z+1,		_color, _alpha, 0, 0, 1, _ao_v4);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z+1,		_color, _alpha, 0, 0, 1, _ao_v6);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z+1,		_color, _alpha, 0, 0, 1, _ao_v7);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z+1,		_color, _alpha, 0, 0, 1, _ao_v7);
                __VertexAdd(_vbuff,	_x+1,	_y,		_z+1,		_color, _alpha, 0, 0, 1, _ao_v5);
                __VertexAdd(_vbuff,	_x,		_y,		_z+1,		_color, _alpha, 0, 0, 1, _ao_v4);
            } else {
                __VertexAdd(_vbuff,	_x+1,	_y,		_z+1,		_color, _alpha, 0, 0, 1, _ao_v5);
                __VertexAdd(_vbuff,	_x,		_y,		_z+1,		_color, _alpha, 0, 0, 1, _ao_v4);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z+1,		_color, _alpha, 0, 0, 1, _ao_v6);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z+1,		_color, _alpha, 0, 0, 1, _ao_v6);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z+1,		_color, _alpha, 0, 0, 1, _ao_v7);
                __VertexAdd(_vbuff,	_x+1,	_y,		_z+1,		_color, _alpha, 0, 0, 1, _ao_v5);
            }
        }
        if !(_neig_03) { // -X
            _ao_v4 = __VertexAO(_neig_21, _neig_16, _neig_23);
            _ao_v6 = __VertexAO(_neig_21, _neig_14, _neig_18);
            _ao_v0 = __VertexAO(_neig_09, _neig_16, _neig_11);
            _ao_v2 = __VertexAO(_neig_09, _neig_14, _neig_06);
            if (_ao_v0 + _ao_v6 > _ao_v4 + _ao_v2) {
                __VertexAdd(_vbuff,	_x,		_y,		_z,	    _color, _alpha, -1, 0, 0, _ao_v0);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z, 	_color, _alpha, -1, 0, 0, _ao_v2);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z+1,	_color, _alpha, -1, 0, 0, _ao_v6);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z+1,	_color, _alpha, -1, 0, 0, _ao_v6);
                __VertexAdd(_vbuff,	_x,		_y,		_z+1,	_color, _alpha, -1, 0, 0, _ao_v4);
                __VertexAdd(_vbuff,	_x,		_y,		_z,	    _color, _alpha, -1, 0, 0, _ao_v0);
            } else {
                __VertexAdd(_vbuff,	_x,		_y,		_z+1,	_color, _alpha, -1, 0, 0, _ao_v4);
                __VertexAdd(_vbuff,	_x,		_y,		_z,	    _color, _alpha, -1, 0, 0, _ao_v0);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z, 	_color, _alpha, -1, 0, 0, _ao_v2);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z, 	_color, _alpha, -1, 0, 0, _ao_v2);
                __VertexAdd(_vbuff,	_x,		_y+1,	_z+1,	_color, _alpha, -1, 0, 0, _ao_v6);
                __VertexAdd(_vbuff,	_x,		_y,		_z+1,	_color, _alpha, -1, 0, 0, _ao_v4);
            }
        }
        if !(_neig_04) { // -Y
            _ao_v5 = __VertexAO(_neig_24, _neig_17, _neig_25);
            _ao_v4 = __VertexAO(_neig_24, _neig_16, _neig_23);
            _ao_v1 = __VertexAO(_neig_12, _neig_17, _neig_13);
            _ao_v0 = __VertexAO(_neig_12, _neig_16, _neig_11);
            if (_ao_v4 + _ao_v1 > _ao_v5 + _ao_v0) {
                __VertexAdd(_vbuff,	_x, 	_y,		_z+1,	_color, _alpha, 0, -1, 0, _ao_v4);
                __VertexAdd(_vbuff,	_x+1,	_y,		_z+1,	_color, _alpha, 0, -1, 0, _ao_v5);
                __VertexAdd(_vbuff,	_x+1,	_y,		_z,	    _color, _alpha, 0, -1, 0, _ao_v1);
                __VertexAdd(_vbuff,	_x+1,	_y,		_z,	    _color, _alpha, 0, -1, 0, _ao_v1);
                __VertexAdd(_vbuff,	_x,		_y,		_z,		_color, _alpha, 0, -1, 0, _ao_v0);
                __VertexAdd(_vbuff,	_x, 	_y,		_z+1,	_color, _alpha, 0, -1, 0, _ao_v4);
            } else {
                __VertexAdd(_vbuff,	_x+1,	_y,		_z+1,	_color, _alpha, 0, -1, 0, _ao_v5);
                __VertexAdd(_vbuff,	_x+1,	_y,		_z,	    _color, _alpha, 0, -1, 0, _ao_v1);
                __VertexAdd(_vbuff,	_x,		_y,		_z,		_color, _alpha, 0, -1, 0, _ao_v0);
                __VertexAdd(_vbuff,	_x,		_y,		_z,		_color, _alpha, 0, -1, 0, _ao_v0);
                __VertexAdd(_vbuff,	_x, 	_y,		_z+1,	_color, _alpha, 0, -1, 0, _ao_v4);
                __VertexAdd(_vbuff,	_x+1,	_y,		_z+1,	_color, _alpha, 0, -1, 0, _ao_v5);
            }
            
        }
        if !(_neig_05) { // -Z
            _ao_v0 = __VertexAO(_neig_12, _neig_09, _neig_11);
            _ao_v1 = __VertexAO(_neig_12, _neig_10, _neig_13);
            _ao_v2 = __VertexAO(_neig_07, _neig_09, _neig_06);
            _ao_v3 = __VertexAO(_neig_07, _neig_10, _neig_08);
            if (_ao_v1 + _ao_v2 > _ao_v0 + _ao_v3) {
                __VertexAdd(_vbuff,	_x+1,	_y,		_z,     _color, _alpha, 0, 0, -1, _ao_v1);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z,     _color, _alpha, 0, 0, -1, _ao_v3);
                __VertexAdd(_vbuff,	_x, 	_y+1,	_z,     _color, _alpha, 0, 0, -1, _ao_v2);
                __VertexAdd(_vbuff,	_x, 	_y+1,	_z,     _color, _alpha, 0, 0, -1, _ao_v2);
                __VertexAdd(_vbuff,	_x,		_y,		_z,     _color, _alpha, 0, 0, -1, _ao_v0);
                __VertexAdd(_vbuff,	_x+1,	_y,		_z,     _color, _alpha, 0, 0, -1, _ao_v1);
            } else {                                        
                __VertexAdd(_vbuff,	_x,		_y,		_z,     _color, _alpha, 0, 0, -1, _ao_v0);
                __VertexAdd(_vbuff,	_x+1,	_y,		_z,     _color, _alpha, 0, 0, -1, _ao_v1);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z,     _color, _alpha, 0, 0, -1, _ao_v3);
                __VertexAdd(_vbuff,	_x+1,	_y+1,	_z,     _color, _alpha, 0, 0, -1, _ao_v3);
                __VertexAdd(_vbuff,	_x, 	_y+1,	_z,     _color, _alpha, 0, 0, -1, _ao_v2);
                __VertexAdd(_vbuff,	_x,		_y,		_z,     _color, _alpha, 0, 0, -1, _ao_v0);
            }
        }
    }

    vertex_end(_vbuff);
	vertex_freeze(_vbuff);
	buffer_delete(_buff);
	return _vbuff;
}


function VoxelCreate(name, sprite, fromBottom = true, zAlign = 1, faceColor = true){

    // Animação 3D
    if (is_array(sprite)) {
        for (var i = 0; i < array_length(sprite); i++) {
            var _sprite = sprite[i];
        }
    }
    
    // Animação 2D
    if (sprite_get_speed(sprite) != 0) {
        for (var i = 0; i < sprite_get_number(sprite); i++) {
            
        }
    }
    
    // Modelo 3D
    __VoxelCache().models[$ name] = {
        frames : [__VoxelCreate(sprite, fromBottom, zAlign)],
    }
}

function VoxelDraw(name, frame, x, y, angleX, angleY) {
    var _mat1 = matrix_build(x, y, 0, 0, angleY, 0, 1, 1, 1)
    var _mat2 = matrix_build(0, 0, 0, angleX, 0, 0, 1, 1, 1)
    VoxelDrawExt(name, frame, matrix_multiply(_mat1, _mat2))
}


function VoxelDrawExt(name, frame, matrix) {
    static u_inv_mat    = shader_get_uniform(shd_voxel_1, "u_inv_mat");
    static mat_identity = matrix_build_identity()
    
    gpu_push_state();
    gpu_set_ztestenable(true);
    gpu_set_zwriteenable(true);
    gpu_set_cullmode(cull_counterclockwise)
    
    shader_set(shd_voxel_1);
    shader_set_uniform_f_array(u_inv_mat, matrix_inverse(matrix_get(matrix_world)))
    
    var _model = __VoxelGet(name)
    var _frames = _model.frames
    
    var _frame = frame mod array_length(_frames)
    vertex_submit(_model.frames[0], pr_trianglelist, -1);
    
    shader_reset();
    gpu_pop_state();
    
    matrix_set(matrix_world, mat_identity)
}

