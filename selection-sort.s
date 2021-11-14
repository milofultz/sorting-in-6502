include "64cube.inc"

; $00-$0f: the working array that will be operated upon and sorted.
; $10-$1f: the control array to check if our results are correct.

enum $30
  seed rBYTE 1                  ; For "random" number generation
  arraySize rBYTE 1             ; Total numbers to be generated, up to #$10
  index rBYTE 1                 ; For tracking current outer iteration
  subIndex rBYTE 1              ; For tracking current inner iteration
  smallest rBYTE 1              ; For tracking smallest number in array
  smallestIndex rBYTE 1         ; For tracking smallest number index in array
ende

  org $200
  sei
  ldx #$ff                      ; Set the stack
  txs

  lda #$f                       ; This will set the video buffer page in a 4k
  sta VIDEO                     ;   page in memory

  lda #$10                      ; Set number of random numbers you want to sort
  sta arraySize                 ; Initialize `arraySize` to above number
  lda #24                       ; Change the seed to create new "random" numbers
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

SelectionSort:
  lda #0                        ; Initialize index at 0
  sta index

  OuterLoop:
  ldx index                     ; Put index into the x register
  stx smallestIndex             ; Set smallestIndex as index
  lda #$00,x                    ; Set smallest as number at index
  sta smallest
  stx subIndex
  inc subIndex                  ; Set subIndex as index after smallestIndex

  InnerLoop:
  lda smallest                  ; Load smallest into the accumulator
  ldx subIndex                  ; Load subIndex into the x register
  cmp #$00,x                    ; If number at subIndex greater than or equal
  bcc NoChange                  ;   to smallest: goto `NoChange`
                                ; Else:
  clc                           ; Clear carry bit because I don't get it yet
  lda #$00,x                    ; Load number at subIndex into accumulator
  sta smallest                  ; Store number into smallest
  stx smallestIndex             ; Store subIndex into smallestIndex
  NoChange:
  inc subIndex                  ; Increment subIndex
  lda arraySize                 ; Load arraySize into the accumulator
  cmp subIndex                  ; If arraySize and subIndex don't match:
  bne InnerLoop                 ;   Goto InnerLoop
                                ; Else:
  lda smallestIndex             ; Load smallestIndex into the accumulator
  sta subIndex                  ; Store smallestIndex into subIndex

  ldx index
  lda #$00,x                    ; Load number at index into accumulator
  tay
  ldx smallestIndex
  lda #$00,x                    ; Load number at smallestIndex into accumulator
  sty #$00,x                    ; Store number at index into smallestIndex
  ldx index
  sta #$00,x                    ; Store number at smallestIndex into index

  lda smallest                  ; Load smallest into the accumulator
  ldx index                     ; Load index into the x register
  sta #$00,x                    ; Store smallest at index
  inc index                     ; Increment the index
  ldx arraySize                 ; Load arraySize into the x register
  dex                           ; Decrement the x register
  cpx index                     ; If (arraySize - 1) minus index is not zero:
  bne OuterLoop                 ;   Goto OuterLoop

Infinite:
  jmp Infinite


IRQ:
  rti
