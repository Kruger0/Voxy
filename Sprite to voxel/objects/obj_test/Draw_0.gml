
var _mat = matrix_build(px, py, pz, rx, ry, rz, sx, sy, sz)
var _mx = device_mouse_x_to_gui(0)
var _my = device_mouse_y_to_gui(0)

//VoxelDraw("model", 0, _mx, _my, 30, current_time/80)
//VoxelDrawExt("model", 0, _mat)
draw_text(_mx, _my, "What")

    
    gpu_push_state();
    gpu_set_ztestenable(true);
    gpu_set_zwriteenable(true);
    gpu_set_cullmode(cull_counterclockwise)
    
    shader_set(shd_voxel_1);
    shader_set_uniform_f_array(shader_get_uniform(shd_voxel_1, "u_inv_mat"), matrix_inverse(matrix_get(matrix_world)))
    
    matrix_set(matrix_world, _mat)
    vertex_submit(model, pr_trianglelist, -1);
    
    shader_reset();
    gpu_pop_state();
    
    matrix_set(matrix_world, matrix_build_identity())