[![GitHub license](https://img.shields.io/github/license/Kruger0/Voxy)](https://github.com/Kruger0/Voxy/blob/main/LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/Kruger0/Voxy)](https://github.com/Kruger0/Voxy/releases)
[![GameMaker](https://img.shields.io/badge/GameMaker-2026_LTS+-blue?logo=gamemaker)](https://gamemaker.io/)
[![GitHub last commit](https://img.shields.io/github/last-commit/Kruger0/Voxy)](https://github.com/Kruger0/Voxy/commits)

<div align="center">
<h1>Voxy 1.0.0</h1>
  <img src="example.png" alt="Voxy Example" width="512">
</div>

Voxy is a sprite-to-voxel mesh library for GameMaker. It converts 2D sprites into fast and optimized 3D voxel vertex buffers at runtime, with support for static models, frame-by-frame animations, face shading, and build-time mesh transforms.

## How to use!

1. Copy the Voxy scripts into your project. In a persistent object or game start event, initialize the vertex format:
   ```js
   VoxyInit();
   ```

2. Create a static voxel model from a sprite:
   ```js
   // All frames are stacked along the Z axis into a single mesh
   VoxyModelCreateStatic("tree", spr_tree);
   ```

3. Create an animated voxel model:
   ```js
   // Each frame becomes its own mesh, played back by index
   VoxyModelCreateAnimated("player", spr_player);
   ```

4. Draw a model in a Draw event. Set your world matrix first, then call:
   ```js
   // Static
   matrix_set(matrix_world, matrix_build(x, y, 0, 0, 0, 0, 1, 1, 1));
   VoxyModelDraw("tree");

   // Animated
   matrix_set(matrix_world, matrix_build(x, y, 0, 0, 0, 0, 1, 1, 1));
   VoxyModelDraw("player", image_index);
   
   matrix_set(matrix_world, matrix_build_identity());
   ```

## Features

### Face Shading
Voxy bakes directional brightness into vertex colors at build time, similar to Minecraft's flat shading. No runtime lighting cost.

Face brightness defaults: `+Z` top → `1.0`, `±Y` sides → `0.8`, `±X` sides → `0.6`, `-Z` bottom → `0.5`.

Override the defaults before creating models:
```js
// [+X, +Y, +Z, -X, -Y, -Z]
VoxyModelSetBrightness([0.7, 0.9, 1.0, 0.7, 0.9, 0.4]);
VoxyModelCreateStatic("tree", spr_tree);
```

Disable shading entirely per model:
```js
VoxyModelCreateStatic("tree", spr_tree, false);
```

### Build-time Transform
Apply a matrix to all vertex positions during mesh baking. Useful for axis remapping or permanent rotations:
```js
// Rotate the mesh 90 degrees on X before baking
VoxyModelSetMatrix(matrix_build(0, 0, 0, 90, 0, 0, 1, 1, 1));
VoxyModelCreateStatic("tree", spr_tree);
```

The matrix persists until changed again.

### Z Offset
Shift the mesh origin along the Z axis at build time:
```js
VoxyModelCreateStatic("tree", spr_tree, true, -8);
```

### Model Management
```js
// Check if a model exists before drawing
if (VoxyModelExists("tree")) {
    VoxyModelDraw("tree");
}

// Free a model from memory when no longer needed
VoxyModelDestroy("tree");
```

## Coordinate System
Voxy uses GameMaker's default left-handed coordinate system: X right, Y down, Z forward. Sprite pixels map to X/Y and animation frames stack along Z for static models. Use `VoxyModelSetMatrix` or the draw matrix to remap axes if needed.

## Complete API Reference

### Models
- `VoxyModelCreateStatic(name, sprite, [shaded], [zOff])` — Bake all sprite frames into a single Z-stacked voxel mesh
- `VoxyModelCreateAnimated(name, sprite, [shaded], [zOff])` — Bake each sprite frame into its own voxel mesh
- `VoxyModelDraw(name, [frame])` — Submit a model for rendering using the current world matrix
- `VoxyModelExists(name)` — Returns whether a model is registered
- `VoxyModelDestroy(name)` — Free all vertex buffers and remove the model from the registry

### Configuration
- `VoxyModelSetBrightness(brightness)` — Override face brightness values `[+X, +Y, +Z, -X, -Y, -Z]`
- `VoxyModelSetMatrix(matrix)` — Set a build-time transform matrix applied to all vertex positions