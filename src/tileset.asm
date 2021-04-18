;;;=========================================================================;;;
;;; Copyright 2020 Matthew D. Steele <mdsteele@alum.mit.edu>                ;;;
;;;                                                                         ;;;
;;; This file is part of Big2Small.                                         ;;;
;;;                                                                         ;;;
;;; Big2Small is free software: you can redistribute it and/or modify it    ;;;
;;; under the terms of the GNU General Public License as published by the   ;;;
;;; Free Software Foundation, either version 3 of the License, or (at your  ;;;
;;; option) any later version.                                              ;;;
;;;                                                                         ;;;
;;; Big2Small is distributed in the hope that it will be useful, but        ;;;
;;; WITHOUT ANY WARRANTY; without even the implied warranty of              ;;;
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU       ;;;
;;; General Public License for more details.                                ;;;
;;;                                                                         ;;;
;;; You should have received a copy of the GNU General Public License along ;;;
;;; with Big2Small.  If not, see <http://www.gnu.org/licenses/>.            ;;;
;;;=========================================================================;;;

INCLUDE "src/macros.inc"
INCLUDE "src/tileset.inc"
INCLUDE "src/vram.inc"

;;;=========================================================================;;;

SKIP_TO_TILE: MACRO
    STATIC_ASSERT _NARG == 1
    ld hl, Vram_SharedTiles + ((\1) - $80) * sizeof_TILE
ENDM

;;;=========================================================================;;;

SECTION "TilesetFunctions", ROM0

;;; Populates Vram_SharedTiles with tile data for the specified tileset.
;;; @param b The TILESET_* enum value.
Func_LoadTileset::
    ld hl, Vram_SharedTiles  ; dest
    ld a, b
    if_ge TILESET_PUZZ_MIN, jr, _LoadTileset_Puzz
_LoadTileset_Map:
    push af
    COPY_FROM_ROMX DataX_SharedMapTiles_start, DataX_SharedMapTiles_end
    pop af
    if_eq TILESET_MAP_FOREST, jp, _LoadTileset_MapForest
    if_eq TILESET_MAP_SEWER, jp, _LoadTileset_MapSewer
    if_eq TILESET_MAP_SPACE, jp, _LoadTileset_MapSpace
    if_eq TILESET_MAP_WORLD, jp, _LoadTileset_MapWorld
    ret
_LoadTileset_Puzz:
    push af
    COPY_FROM_ROMX DataX_SharedTerrainTiles_start, DataX_SharedTerrainTiles_end
    pop af
    if_eq TILESET_PUZZ_CITY, jp, _LoadTileset_PuzzCity
    if_eq TILESET_PUZZ_FARM, jp, _LoadTileset_PuzzFarm
    if_eq TILESET_PUZZ_LAKE, jp, _LoadTileset_PuzzLake
    if_eq TILESET_PUZZ_MOUNTAIN, jp, _LoadTileset_PuzzMountain
    if_eq TILESET_PUZZ_SEWER, jp, _LoadTileset_PuzzSewer
    if_eq TILESET_PUZZ_SPACE, jp, _LoadTileset_PuzzSpace
    ret

_LoadTileset_MapForest:
    SKIP_TO_TILE $90
    COPY_FROM_ROMX DataX_ForestMapTiles_start, DataX_ForestMapTiles_end
    SKIP_TO_TILE $e0
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    COPY_FROM_ROMX DataX_MapRiverTiles_start, DataX_MapRiverTiles_end
    xld hl, DataX_OceanTiles_tile_arr
    jp Func_SetAnimatedTerrain
_LoadTileset_MapSewer:
    SKIP_TO_TILE $c0
    COPY_FROM_ROMX DataX_SewerMapTiles_start, DataX_SewerMapTiles_end
    xld hl, DataX_OceanTiles_tile_arr
    jp Func_SetAnimatedTerrain
_LoadTileset_MapSpace:
    SKIP_TO_TILE $c0
    COPY_FROM_ROMX DataX_SpaceMapTiles_start, DataX_SpaceMapTiles_end
    xld hl, DataX_TwinkleTiles_tile_arr
    jp Func_SetAnimatedTerrain
_LoadTileset_MapWorld:
    SKIP_TO_TILE $e0
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    xld hl, DataX_OceanTiles_tile_arr
    jp Func_SetAnimatedTerrain
_LoadTileset_PuzzCity:
    SKIP_TO_TILE $d0
    COPY_FROM_ROMX DataX_FenceChainTiles_start, DataX_FenceChainTiles_end
    SKIP_TO_TILE $e0
    COPY_FROM_ROMX DataX_CityTiles_start, DataX_CityTiles_end
    ret
_LoadTileset_PuzzFarm:
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    SKIP_TO_TILE $d0
    COPY_FROM_ROMX DataX_FenceWoodTiles_start, DataX_FenceWoodTiles_end
    SKIP_TO_TILE $f0
    COPY_FROM_ROMX DataX_BarnTiles_start, DataX_BarnTiles_end
    xld hl, DataX_CowBlinkTiles_tile_arr
    jp Func_SetAnimatedTerrain
_LoadTileset_PuzzLake:
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    COPY_FROM_ROMX DataX_BridgeTiles_start, DataX_BridgeTiles_end
    SKIP_TO_TILE $d0
    COPY_FROM_ROMX DataX_FenceWoodTiles_start, DataX_FenceWoodTiles_end
    xld hl, DataX_OceanTiles_tile_arr
    jp Func_SetAnimatedTerrain
_LoadTileset_PuzzMountain:
    COPY_FROM_ROMX DataX_RiverTiles_start, DataX_RiverTiles_end
    COPY_FROM_ROMX DataX_BridgeTiles_start, DataX_BridgeTiles_end
    SKIP_TO_TILE $d0
    COPY_FROM_ROMX DataX_MountainTiles_start, DataX_MountainTiles_end
    ret
_LoadTileset_PuzzSewer:
    COPY_FROM_ROMX DataX_EdgeTiles_start, DataX_EdgeTiles_end
    SKIP_TO_TILE $c0
    COPY_FROM_ROMX DataX_BridgeTiles_start, DataX_BridgeTiles_end
    SKIP_TO_TILE $e0
    COPY_FROM_ROMX DataX_BrickTiles_start, DataX_BrickTiles_end
    xld hl, DataX_OceanTiles_tile_arr
    jp Func_SetAnimatedTerrain
_LoadTileset_PuzzSpace:
    COPY_FROM_ROMX DataX_GirderTiles_start, DataX_GirderTiles_end
    SKIP_TO_TILE $e0
    COPY_FROM_ROMX DataX_SpaceTiles_start, DataX_SpaceTiles_end
    xld hl, DataX_StarsTiles_tile_arr
    jp Func_SetAnimatedTerrain

;;;=========================================================================;;;

;;; @param b The TILESET_* enum value.
;;; @param c The animation counter (0-255).
Func_AnimateTerrain::
    ld a, b
    if_eq TILESET_MAP_SPACE, jr, _AnimateTerrain_Twinkle
    if_eq TILESET_PUZZ_CITY, ret
    if_eq TILESET_PUZZ_FARM, jr, _AnimateTerrain_Cow
    if_eq TILESET_PUZZ_MOUNTAIN, ret
    if_eq TILESET_PUZZ_SPACE, jr, _AnimateTerrain_Stars
_AnimateTerrain_Ocean:
    ld a, c
    and %00001111
    ret nz
    ld a, c
    and %00010000
    ASSERT sizeof_TILE == 16
    ldb de, a
    xld hl, DataX_OceanTiles_tile_arr
    jr _AnimateTerrain_Copy
_AnimateTerrain_Cow:
    ld a, c
    and %01111111
    jr z, .blink
    if_ne 10, ret
    ld a, sizeof_TILE
    .blink
    ldb de, a
    xld hl, DataX_CowBlinkTiles_tile_arr
    jr _AnimateTerrain_Copy
_AnimateTerrain_Stars:
    ld a, c
    and %00000111
    ASSERT sizeof_TILE == 16
    swap a
    ldb de, a
    xld hl, DataX_StarsTiles_tile_arr
    jr _AnimateTerrain_Copy
_AnimateTerrain_Twinkle:
    ld a, c
    and %00000111
    ret nz
    ld a, c
    and %00011000
    ASSERT sizeof_TILE == 16
    rlca
    ldb de, a
    xld hl, DataX_TwinkleTiles_tile_arr
_AnimateTerrain_Copy:
    add hl, de
    ;; fall through to Func_SetAnimatedTerrain

;;; @prereq Correct ROM bank for hl pointer is set.
;;; @param hl A pointer to the tile to copy.
Func_SetAnimatedTerrain:
    ld de, Vram_BgTiles + sizeof_TILE * ANIMATED_TILE_ID
    REPT sizeof_TILE - 1
    ld a, [hl+]
    ld [de], a
    inc e
    ENDR
    ld a, [hl]
    ld [de], a
    ret

;;;=========================================================================;;;
