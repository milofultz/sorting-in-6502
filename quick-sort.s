include "64cube.inc"

; $00-$0f: the working array that will be operated upon and sorted.
; $10-$1f: the control array to check if our results are correct.

enum $30
  seed rBYTE 1                  ; For "random" number generation
  arraySize rBYTE 1             ; Total numbers to be generated, up to #$10
  pivot rBYTE 1                 ; Track pivot index
  index rBYTE 1                 ; Track index
  lowBoundary rBYTE 1           ; Track array boundaries
  highBoundary rBYTE 1
ende

  org $200
  sei
  ldx #$ff                      ; Set the stack
  txs

  lda #$f                       ; This will set the video buffer page in a 4k
  sta VIDEO                     ;   page in memory

  lda #$10                      ; Set number of random numbers you want to sort
  sta arraySize                 ; Initialize `arraySize` to above number
  lda #3                        ; Change the seed to create new "random" numbers
  sta seed

  _setw IRQ, VBLANK_IRQ

  cli

SetSortaRandomNumbers:          ; This is a really bad pseudo random number
  lda #0                        ;   generator. I wouldn't worry about what is
  sta index                     ;   going on here, if not just for my sake
  lda seed
  tay
randLoop:
  tya
  asl
  rol a
  adc #$c
  clc
  ldx index
  sta $00,x
  sta $10,x
  tay
  inc index
  lda index
  cmp arraySize
  bne randLoop


QuickSort:
  lda #0
  pha                           ; Push low index in the array onto the stack
  lda arraySize
  sec
  sbc #1
  pha                           ; Push high index in the array onto the stack

  Sort:
  tsx
  txa                           ; Load current stack address into accumulator
  cmp #$ff                      ; If stack is empty:
  beq Infinite                  ;   Goto end (all arrays are sorted)

  pla                           ; Pull high index from the stack
  sta highBoundary              ; Store in highBoundary and in pivot
  sta pivot
  pla                           ; Pull low index from the stack
  sta lowBoundary               ; Store in lowBoundary and in index
  sta index
  cmp pivot                     ; if pivot <= index:
  bcs Sort                      ;   Goto Sort

  lda arraySize                 ; Load arraySize into accumulator
  cmp index                     ; if index < 0 (e.g. $ff):
  bcc Sort                      ;   Goto Sort
  cmp pivot                     ; if pivot < 0 (e.g. $ff):
  bcc Sort                      ;   Goto Sort

  Split:
  lda pivot                     ; Load pivot into accumulator
  sec
  sbc index                     ; If subarray is empty:
  beq Sort                      ;   Goto Sort (nothing to sort)
  cmp #1                        ; If subarray length is 1:
  beq Sort                      ;   Goto Sort (already sorted)

  PlacePivot:
  ldx index
  lda #$00,x                    ; Load number at index into the accumulator
  ldx pivot
  cmp #$00,x                    ; If number at pivot > number at index
  bcs SwapNumbers               ;   Goto SwapNumbers
                                ; Else:
  inc index                     ; Increment index
  jmp CheckPivot                ; Goto CheckPivot

  SwapNumbers:
  ldx index
  lda #$00,x                    ; Load number at index to accumulator
  tay                           ; Transfer into Y register
  ldx pivot
  dex
  lda #$00,x                    ; Load number at (pivot - 1) into the accumulator
  sty #$00,x                    ; Store number at index at (pivot - 1) address
  ldx index
  sta #$00,x                    ; Store number at (pivot - 1) at index address

  ldx pivot
  dex
  lda #$01,x                    ; Load number at pivot into the accumulator
  ldy #$00,x                    ; Load number at (pivot - 1) into Y
  sta #$00,x                    ; Store number at pivot into (pivot - 1)
  sty #$01,x                    ; Store number at (pivot - 1) into pivot

  dec pivot                     ; Decrement pivot

  CheckPivot:
  lda pivot                     ; Load number at pivot into the accumulator
  cmp index                     ; If pivot !== index (if pivot in place):
  bne PlacePivot                ;   Goto PlacePivot

  AddArraysToStack:
  lda lowBoundary               ; Load low index of sub-array to accumulator
  pha                           ; Push low point to stack
  dec index
  lda index                     ; Load high point of sub-array to accumulator
  pha                           ; Push high point to stack
  inc pivot
  lda pivot                     ; Load low index of super-array to accumulator
  pha                           ; Push low point to stack
  lda highBoundary              ; Load high point of sub-array to accumulator
  pha                           ; Push high point to stack

  jmp Sort                      ; Sort next array found in the stack


Infinite:
  jmp Infinite

IRQ:
  rti

