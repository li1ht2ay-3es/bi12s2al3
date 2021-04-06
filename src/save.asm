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

INCLUDE "src/hardware.inc"
INCLUDE "src/macros.inc"
INCLUDE "src/save.inc"

;;;=========================================================================;;;

SECTION "Sram", SRAM, BANK[0]

Sram_Save0_file:
    DS sizeof_FILE
Sram_Save1_file:
    DS sizeof_FILE
Sram_Save2_file:
    DS sizeof_FILE
ASSERT NUM_SAVE_FILES == 3

;;;=========================================================================;;;

SECTION "Progress", WRAM0, ALIGN[8]

Ram_Progress_file::
    DS sizeof_FILE

;;;=========================================================================;;;

SECTION "SaveState", WRAM0

;;; The most recently loaded save file number.
Ram_SaveFileNumber_u8:
    DB

;;; An array of SAVE structs that summarize the state of the save files.
Ram_SaveSummaries_save_arr:
    DS sizeof_SAVE * NUM_SAVE_FILES

;;;=========================================================================;;;

SECTION "SaveFunctions", ROM0

;;; If the specified save file is not empty, loads it into Ram_Progress_file.
;;; Otherwise, starts a new game in Ram_Progress_file, and saves it to the
;;; specified save file.
;;; @param b The save file number to load from.
Func_LoadFile::
    ld a, b
    ld [Ram_SaveFileNumber_u8], a
    ;; If the save file is empty, start a new game.
    call Func_GetSaveSummaryPtr_hl  ; preserves b
    ASSERT SAVE_Exists_bool == 1
    inc hl
    bit 0, [hl]
    jr z, _LoadFile_NewGame
    ;; Otherwise, load the save file in Ram_Progress_file.
    call Func_GetSaveFilePtr_hl
    ldw de, hl
    ld hl, Ram_Progress_file
    jr Func_SramFileTransfer

_LoadFile_NewGame:
    ;; Mark all puzzles as locked and unsolved.
    ld c, NUM_PUZZLES
    ld hl, Ram_Progress_file + FILE_PuzzleStatus_u8_arr
    xor a
    .loop
    ld [hl+], a
    dec c
    jr nz, .loop
    ;; Set the current puzzle to the first one.
    ld [Ram_Progress_file + FILE_CurrentPuzzleNumber_u8], a
    ;; Mark the file as existent.
    ld a, MAGIC_FILE_EXISTS
    ld [Ram_Progress_file + FILE_Magic_u8], a
    ;; fall through to Func_SaveFile

;;; Saves Ram_Progress_file to the current save file in SRAM.
Func_SaveFile::
    ;; Update the save summary.
    ld hl, Ram_Progress_file  ; param: FILE ptr
    call Func_GetFileNumSolvedPuzzlesBcd_c
    ld a, [Ram_SaveFileNumber_u8]
    ld b, a  ; param: save file number
    call Func_GetSaveSummaryPtr_hl  ; preserves b
    ASSERT SAVE_NumSolvedPuzzles_bcd8 == 0
    ld a, c
    ld [hl+], a
    ASSERT SAVE_Exists_bool == 1
    ld [hl], 1
    ;; Save the file to SRAM.
    call Func_GetSaveFilePtr_hl
    ld de, Ram_Progress_file
    ;; fall through to Func_SramFileTransfer

;;; Copies a FILE struct to/from SRAM.
;;; @param hl Destination start address.
;;; @param de Source start address.
Func_SramFileTransfer:
    ld bc, sizeof_FILE
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a
    call Func_MemCopy
    ld a, CART_SRAM_DISABLE
    ld [rRAMG], a
    ret

;;; Erases the specified save file.
;;; @param b The save file number to erase.
Func_EraseFile::
    ;; Mark the save summary as erased.
    call Func_GetSaveSummaryPtr_hl  ; preserves b
    ASSERT SAVE_Exists_bool == 1
    inc hl
    ld [hl], 0
    ;; Mark the file in SRAM as erased.
    call Func_GetSaveFilePtr_hl
    ld de, FILE_Magic_u8
    add hl, de
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a
    ld [hl], 0
    ld a, CART_SRAM_DISABLE
    ld [rRAMG], a
    ret

;;;=========================================================================;;;

;;; @param hl A pointer to a FILE struct.
;;; @return c The number of solved puzzles in the file, in BCD.
;;; @preserve b
Func_GetFileNumSolvedPuzzlesBcd_c:
    ld c, 0
    ld e, NUM_PUZZLES
    ASSERT FILE_PuzzleStatus_u8_arr == 0
    .loop
    ld a, [hl+]
    bit STATB_SOLVED, a
    jr z, .unsolved
    ld a, c
    add 1
    daa
    ld c, a
    .unsolved
    dec e
    jr nz, .loop
    ret

;;;=========================================================================;;;

;;; Populates each summary SAVE struct from the corresponding SRAM FILE struct.
Func_InitSaveSummaries::
    ld a, CART_SRAM_ENABLE
    ld [rRAMG], a
    ld b, 0
    .loop
    call Func_InitSaveSummary  ; preserves b
    inc b
    ld a, b
    if_lt NUM_SAVE_FILES, jr, .loop
    ld a, CART_SRAM_DISABLE
    ld [rRAMG], a
    ret

;;; Populates the specified summary SAVE struct from the corresponding SRAM
;;; FILE struct.
;;; @param b The save file number.
;;; @preserve b
Func_InitSaveSummary:
    call Func_GetSaveFilePtr_hl  ; preserves b
    ASSERT FILE_Magic_u8 != 0
    ld de, FILE_Magic_u8
    add hl, de
    ld a, [hl]
    if_eq MAGIC_FILE_EXISTS, jr, _InitSaveSummary_NonEmpty
_InitSaveSummary_Empty:
    call Func_GetSaveSummaryPtr_hl  ; preserves b
    ASSERT SAVE_Exists_bool == 1
    inc hl
    ld [hl], 0
    ret
_InitSaveSummary_NonEmpty:
    call Func_GetSaveFilePtr_hl  ; preserves b
    call Func_GetFileNumSolvedPuzzlesBcd_c  ; preserves b
    call Func_GetSaveSummaryPtr_hl  ; preserves bc
    ASSERT SAVE_NumSolvedPuzzles_bcd8 == 0
    ld a, c
    ld [hl+], a
    ASSERT SAVE_Exists_bool == 1
    ld [hl], 1
    ret

;;;=========================================================================;;;

;;; Returns a pointer to the specified save file in SRAM.
;;; @param b The save file number.
;;; @return hl A pointer to a FILE struct in SRAM.
;;; @preserve bc, de
Func_GetSaveFilePtr_hl:
    ld a, b
    ASSERT NUM_SAVE_FILES == 3
    if_eq 2, jr, .file2
    if_eq 1, jr, .file1
    .file0
    ld hl, Sram_Save0_file
    ret
    .file1
    ld hl, Sram_Save1_file
    ret
    .file2
    ld hl, Sram_Save2_file
    ret

;;; Returns a pointer to the specified save summary in WRAM.
;;; @param b The save file number.
;;; @return hl A pointer to a SAVE struct in WRAM.
;;; @preserve bc
Func_GetSaveSummaryPtr_hl::
    ld a, b
    ASSERT NUM_SAVE_FILES * sizeof_SAVE <= $ff
    ASSERT sizeof_SAVE == 2
    rlca
    ldb de, a
    ld hl, Ram_SaveSummaries_save_arr
    add hl, de
    ret

;;;=========================================================================;;;
