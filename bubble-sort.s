include "64cube.inc"

; $00-$0f: the working array that will be operated upon and sorted.
; $10-$1f: the control array to check if our results are correct.

enum $30
  seed rBYTE 1                  ; For "random" number generation
  count rBYTE 1                 ; Total numbers to be generated, up to #$10
  currCount rBYTE 1             ; Used for keeping track of current item
  isSorted rBYTE 1              ; Flag to check if any modifications happened
                                ;   on this most recent sort pass
ende

  org $200
  sei
  ldx #$ff                      ; Set the stack
  txs

  lda #$f                       ; This will set the video buffer page in a 4k
  sta VIDEO                     ;   page in memory

  lda #0
  sta currCount                 ; Initialize currCount to 0
  sta isSorted                  ; Initialize isSorted flag to 0
  lda #$10                      ; Set up to #$10 random numbers you want to sort
  sta count
  lda #24                       ; Change the seed to create new "random" numbers
  sta seed

  _setw IRQ, VBLANK_IRQ

  cli

SetSortaRandomNumbers:          ; This is a really bad pseudo random number
  lda seed                      ;   generator. I wouldn't worry about what is
  tay                           ;   going on here, if not just for my sake
randLoop:
  tya
  asl
  rol a
  adc #$c
  clc
  ldx currCount
  sta $00,x
  sta $10,x
  tay
  inc currCount
  lda currCount
  cmp count
  bne randLoop

BubbleSort:
  OuterLoop:                    ; This loop will iterate through the entire list
  dec count                     ; Handle comparing of two elements. Without
                                ;   this, the final comparison will be with the
                                ;   last number and a number outside of scope
  lda #0
  sta currCount                 ; Initialize currCount to 0
  lda #1
  sta isSorted                  ; Reset the isSorted flag

  InnerLoop:                    ; This loop will compare two numbers for sorting
  ldx currCount                 ; Load currCount into x for addressing memory
  lda $01,x                     ; Load the second number into the accumulator
  cmp $00,x                     ; Subtract the first number from the second
  bcs NextNum                   ; If second num > first num, goto NextNum
                                ; Else, swap the two numbers
  ldy $00,x                     ; Load the first number into the y register
  sta $00,x                     ; Store the second number into first mem slot
  sty $01,x                     ; Store the first number into second mem slot
  dec isSorted                  ; Ensure isSorted is not set to 1
  NextNum:
  lda count                     ; Load count into the accumulator
  inc currCount                 ; Increment currCount
  cmp currCount                 ; If we are on the last number,
  bne InnerLoop                 ;   goto InnerLoop
                                ; Else, continue
  lda isSorted                  ; Load isSorted flag into the accumulator
  cmp #1                        ; If isSorted is not 1 (false)
  bne OuterLoop                 ;   goto OuterLoop
                                ; Else, the list is sorted
Infinite:
  jmp Infinite

IRQ:
  rti

