
game_set_speed(75, gamespeed_fps)
display_reset(8, true)

var _t = get_timer()
//model = VoxelCreate("model", Sprite14, false, 0.5)
model = __VoxelCreate(Sprite14, false, 0.5)
show_debug_message($"Model created in {(get_timer()-_t)/1000}ms")

px = 0
py = 0
pz = 0
rx = 0
ry = 0
rz = 0
sx = 1
sy = 1
sz = 1


dbg_slider(ref_create(self, "px"), 0, 1024)
dbg_slider(ref_create(self, "py"), 0, 1024)
dbg_slider(ref_create(self, "pz"), 0, 1024)
dbg_slider(ref_create(self, "rx"), -180, 180)
dbg_slider(ref_create(self, "ry"), -180, 180)
dbg_slider(ref_create(self, "rz"), -180, 180)
dbg_slider(ref_create(self, "sx"), 0.1, 32)
dbg_slider(ref_create(self, "sy"), 0.1, 32)
dbg_slider(ref_create(self, "sz"), 0.1, 32)

/*

//surface_resize(application_surface, 480, 270)
spr = spr_toast
player = sprite_to_voxel(spr, true, 0.5, 0.5, 0.5)



