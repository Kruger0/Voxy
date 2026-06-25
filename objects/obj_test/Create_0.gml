
px = 0
py = 0
pz = 0
rx = 0
ry = 0
rz = 0
sx = 10
sy = 10
sz = 10

dbg_slider(ref_create(self, "px"), -512, 512)
dbg_slider(ref_create(self, "py"), -512, 512)
dbg_slider(ref_create(self, "pz"), -512, 512)
dbg_slider(ref_create(self, "rx"), -360, 360)
dbg_slider(ref_create(self, "ry"), -360, 360)
dbg_slider(ref_create(self, "rz"), -360, 360)
dbg_slider(ref_create(self, "sx"), 0.1, 32)
dbg_slider(ref_create(self, "sy"), 0.1, 32)
dbg_slider(ref_create(self, "sz"), 0.1, 32)

VoxyModelSetMatrix(matrix_build(0, 0, 0, 180, 0, 0, 2, 2, 2))
VoxyModelCreateStatic("house", spr_toast, true, 0.5);
