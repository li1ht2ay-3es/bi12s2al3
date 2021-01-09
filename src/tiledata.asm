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

INCLUDE "src/vram.inc"

;;;=========================================================================;;;

SECTION "FontTiles", ROM0
Data_FontTiles_start::
    INCBIN "out/data/font.2bpp"
Data_FontTiles_end::

;;;=========================================================================;;;

SECTION "MapTiles", ROM0
Data_MapTiles_start::
    INCBIN "out/data/worldmap.2bpp"
Data_MapTiles_end::

;;;=========================================================================;;;

SECTION "ObjTiles", ROM0
Data_ObjTiles_start::
    INCBIN "out/data/elephant.2bpp"
    INCBIN "out/data/goat.2bpp"
    INCBIN "out/data/mouse.2bpp"
    INCBIN "out/data/cursor.2bpp"
    INCBIN "out/data/smoke.2bpp"
Data_ObjTiles_end::

;;;=========================================================================;;;

SECTION "DeviceTiles", ROM0
Data_DeviceTiles_start::
    INCBIN "out/data/devices.2bpp"
Data_DeviceTiles_end::

;;;=========================================================================;;;

SECTION "TerrainTiles", ROM0
Data_TerrainTiles_start::
    INCBIN "out/data/forest.2bpp"
    INCBIN "out/data/mountain.2bpp"
Data_TerrainTiles_end::

;;;=========================================================================;;;

SECTION "CityTiles", ROM0
Data_CityTiles_start::
    INCBIN "out/data/city.2bpp"
    DS sizeof_TILE * 4
    INCBIN "out/data/space.2bpp"
Data_CityTiles_end::

;;;=========================================================================;;;

SECTION "RiverTiles", ROM0
Data_RiverTiles_start::
    INCBIN "out/data/river.2bpp"
    INCBIN "out/data/pipe.2bpp"
Data_RiverTiles_end::

;;;=========================================================================;;;
