
var _cam = camera_get_active();
camera_set_view_mat(_cam, matrix_build_lookat(64, 64, 64, px, py, pz, 0, 0, -1))
camera_set_proj_mat(_cam, matrix_build_projection_perspective_fov(70, 16/9, 0.1, 16000))
camera_apply(_cam)

gpu_push_state();
gpu_set_ztestenable(true);
gpu_set_zwriteenable(true);
gpu_set_cullmode(cull_clockwise);
matrix_set(matrix_world, matrix_build(px, py, pz, rx, ry, rz, sx, sy, sz))

VoxyModelDraw("house", current_time/100);

gpu_pop_state();
matrix_set(matrix_world, matrix_build_identity())

