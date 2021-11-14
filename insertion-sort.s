include "64cube.inc"

; $00-$0f: the working array that will be operated upon and sorted.
; $10-$1f: the control array to check if our results are correct.

enum $30
  seed rBYTE 1                  ; For "random" number generation
  arraySize rBYTE 1             ; Total numbers to be generated, up to #$10
  index rBYTE 1                 ; Track current outer iteration
  indexNum rBYTE 1              ; Track number found at #$00,index
  subIndex rBYTE 1              ; Track current inner iteration
ende

  org $200
  sei
  ldx #$ff                      ; Set the stack
  txs

  lda #$f                       ; This will set the video buffer page in a 4k
  sta VIDEO                     ;   page in memory

  lda #$10                      ; Set number of random numbers you want to sort
  sta arraySize                 ; Initialize `arraySize` to above number
  lda #20                       ; Change the seed to create new "random" numbers
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

InsertionSort:
  ldx #1
  stx index                     ; Initialize index at 1

  OuterLoop:
  ldx index                     ; Load index into X
  lda #$00,x                    ; Load number at #$00,x into the accumulator
  sta indexNum                  ; Store number in accumulator at indexNum
  stx subIndex                  ; Store number in X at subIndex

  InnerLoop:
  dec subIndex                  ; Decrement subIndex
  lda subIndex                  ; Load subIndex into the accumulator
  cmp #$ff                      ; If subIndex decremented past the beginning:
  beq InsertIndexNum            ;   Goto Insert
                                ; Else:
  ldx subIndex                  ; Load subIndex into x
  lda #$00,x                    ; Load number at #$00,x into the accumulator
  sta #$01,x                    ; Store number in accumulator at #$01,x
  cmp indexNum                  ; If indexNum <= subIndex number:
  bcs InnerLoop                 ;   Goto InnerLoop

  InsertIndexNum:               ; Insert indexNum at one above current subIndex
  inc subIndex                  ; Increment subIndex
  ldx subIndex                  ; Load subIndex into X
  lda indexNum                  ; Load indexNum into the accumulator
  sta #$00,x                    ; Store number at #$00,x into the accumulator

  InPlace:
  inc index                     ; Increment index
  lda arraySize                 ; Load arraySize into the accumulator
  cmp index                     ; If index !== arraySize:
  bne OuterLoop                 ;   Goto OuterLoop


Infinite:
  jmp Infinite


IRQ:
  rti
