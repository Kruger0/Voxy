
/// @desc Converts a sprite into a single static voxel mesh.
/// @param {string} name Registry key used to reference this model.
/// @param {Asset.GMSprite} sprite Source sprite asset.
/// @param {bool} shaded Bake face shading into vertex colors. Default: true.
/// @param {real} zOff Z offset applied to the mesh origin. Default: 0.
function VoxyModelCreateStatic(name, sprite, shaded = true, zOff = 0) {
    static __data = VoxyInit();
    if (struct_exists(__data.models, name)) {
        show_debug_message($"[VOXY] - Model '{name}' already exists.");
        return;
    }
    var _sWidth = sprite_get_width(sprite);
    var _sHeight = sprite_get_height(sprite);
    var _sXOff = sprite_get_xoffset(sprite);
    var _sYOff = sprite_get_yoffset(sprite);
    var _sNumber = sprite_get_number(sprite);
    var _buff = VoxyRawCreate(sprite, -1, _sWidth, _sHeight, _sXOff, _sYOff, _sNumber);
    var _vbuff = VoxyRawSolidify(_buff, _sWidth, _sHeight, _sXOff, _sYOff, zOff, _sNumber, shaded);
    __data.models[$ name] = {
        frames: [_vbuff],
        number: 1,
        shaded,
    };
    show_debug_message($"[VOXY] - Model '{name}' created.");
}

/// @desc Converts each frame of a sprite into its own voxel mesh.
/// @param {string} name Registry key used to reference this model.
/// @param {Asset.GMSprite} sprite  Source sprite asset.
/// @param {bool} shaded Bake face shading into vertex colors. Default: true.
/// @param {real} zOff Z offset applied to the mesh origin. Default: 0.
function VoxyModelCreateAnimated(name, sprite, shaded = true, zOff = 0) {
    static __data = VoxyInit();
    if (struct_exists(__data.models, name)) {
        show_debug_message($"[VOXY] - Model '{name}' already exists.");
        return;
    }
    var _sWidth = sprite_get_width(sprite);
    var _sHeight = sprite_get_height(sprite);
    var _sXOff = sprite_get_xoffset(sprite);
    var _sYOff = sprite_get_yoffset(sprite);
    var _sNumber = sprite_get_number(sprite);
    var _model = { 
        frames: array_create(_sNumber),
        number: _sNumber,
        shaded,
    };
    for (var i = 0; i < _sNumber; i++) {
        var _buff = VoxyRawCreate(sprite, i, _sWidth, _sHeight, _sXOff, _sYOff, _sNumber);
        _model.frames[i] = VoxyRawSolidify(_buff, _sWidth, _sHeight, _sXOff, _sYOff, zOff, 1, shaded);
    }
    __data.models[$ name] = _model;
    show_debug_message($"[VOXY] - Model '{name}' created.");
}

/// @desc Submits a voxel model for rendering.
/// @param {string} name Registry key of the model to draw.
/// @param {real} frame Frame index for animated models. Default: 0.
function VoxyModelDraw(name, frame = 0) {
    static __data = VoxyInit();
    if (!struct_exists(__data.models, name)) {
        show_debug_message($"[VOXY] - Model '{name}' not found.");
        return;
    }
    var _model = __data.models[$ name];
    var _frame = frame mod _model.number;
    vertex_submit(_model.frames[_frame], pr_trianglelist, -1);
}

/// @desc Frees all vertex buffers associated with a model and removes it from the registry.
/// @param {string} name Registry key of the model to destroy.
function VoxyModelDestroy(name) {
    static __data = VoxyInit();
    if (!struct_exists(__data.models, name)) {
        show_debug_message($"[VOXY] - Model '{name}' not found.");
        return;
    }
    var _model = __data.models[$ name];
    for (var i = 0; i < _model.number; i++) {
        vertex_delete_buffer(_model.frames[i]);
    }
    struct_remove(__data.models, name);
}

/// @desc Returns whether a model is registered.
/// @param {string} name Registry key to check.
/// @returns {bool}
function VoxyModelExists(name) {
    static __data = VoxyInit();
    return struct_exists(__data.models, name);
}

/// @desc Set the face brightness values used during mesh baking. Array order: [+X, +Y, +Z, -X, -Y, -Z].
/// @param {Array<real>} brightness 6-element array of brightness multipliers (0.0 - 1.0).
function VoxyModelSetBrightness(brightness) {
    static __data = VoxyInit();
    __data.brightness = brightness;
}

/// @desc Sets a build-time transform matrix applied to all vertex positions during mesh baking.
/// @param {Array<real>} matrix A 4x4 matrix array (e.g. from matrix_build).
function VoxyModelSetMatrix(matrix) {
    static __data = VoxyInit();
    __data.matrix = matrix;
}
