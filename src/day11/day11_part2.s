
.global _main

.include "macros.s"

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4
fileSize:       .quad           10000
splitToken:     .asciz          "\n"


.bss
fileBuffer:     .lcomm          fbuffer, 10000
lineBuffer:     .lcomm          lbuffer, 128
offsetB:        .lcomm          obuffer, 128
answerBuffer:   .lcomm          abuffer, 8740
offsetC:        .lcomm          dbuffer, 128
checkBuffer:    .lcomm          cbuffer, 8740
# ------------------------------------------------------------- #
.macro cswpo    offset end
                push            rdi

checkSeats_pos_loop_\offset:
                add             rdi, \offset

                cmp             rdi, \end
                jg              checkSeats_pos_\offset

                cmp             byte ptr [rdi], 'L'
                je              checkSeats_pos_\offset

                cmp             byte ptr [rdi], '#'
                jne             checkSeats_pos_loop_\offset
                inc             rbx

checkSeats_pos_\offset:
                pop             rdi
.endm

.macro cswno    offset end
                push            rdi

checkSeats_neg_loop_\offset:
                sub             rdi, \offset

                cmp             rdi, \end
                jl              checkSeats_neg_\offset

                cmp             byte ptr [rdi], 'L'
                je              checkSeats_neg_\offset

                cmp             byte ptr [rdi], '#'
                jne             checkSeats_neg_loop_\offset
                inc             rbx

checkSeats_neg_\offset:
                pop             rdi
.endm

# ------------------------------------------------------------- #
# Main
.text
_main:
                oftb            [inputsFileName + RIP], [fileBuffer + RIP], [fileSize + RIP]
# ------------------------------------------------------------- #
                lea             rdx, [fileBuffer + RIP]
                xor             r11, r11
                lea             rcx, [answerBuffer + RIP]

splitLoop:
                cmp             byte ptr [rdx], 0               // check for null, finished when no more lines
                je              finishedSplit

                // split into an array
                ssbtr           rcx, [splitToken + RIP]
                jmp             splitLoop
finishedSplit:
                xor             r11, 1
                xor             rax, rax
iterationLoop:
                push            r11
                call            checkSeats
                call            updatedSeats
                pop             r11

                cmp             r11, rax
                je              finished
                mov             r11, rax
                jmp             iterationLoop
finished:
                mov             rax, r11
                call            printInteger                    // print result
                call            exit

# ------------------------------------------------------------- #
# check each seat
checkSeats:
                lea             rdi, [answerBuffer + RIP]
                lea             rdx, [checkBuffer + RIP]
                xor             rcx, rcx
                jmp             checkSeats_start
checkSeats_loop:
                inc             rdi
                inc             rdx

                inc             rcx
                cmp             rcx, 95
                jne             checkSeats_start
                xor             rcx, rcx

checkSeats_start:
                cmp             byte ptr [rdi], 0
                je              checkSeats_finished

                cmp             byte ptr [rdi], '.'
                je              checkSeats_loop

                xor             rbx, rbx

                // check if at left side

                mov             rsi, rdi
                sub             rsi, rcx
                lea             r12, [answerBuffer + RIP]
                lea             r13, [answerBuffer + RIP + 8740]

                cmp             rcx, 0
                je              checkSeats_left

                cswpo           94, r13
                cswno           96, r12
                cswno           1, rdi
checkSeats_left:
                // check if at right side
                cmp             rcx, 94
                je              checkSeats_right

                cswno           94, r12
                add             rsi, 94
                cswpo           1, rsi
                cswpo           96, r13

checkSeats_right:
                cswno           95, r12
                cswpo           95, r13

                cmp             byte ptr [rdi], '#'
                jne             checkSeats_isSeat

                cmp             rbx, 5
                jl              checkSeats_occupied

                mov             byte ptr [rdx], 'L'
                jmp             checkSeats_loop
checkSeats_occupied:
                mov             byte ptr [rdx], '#'
                jmp             checkSeats_loop

checkSeats_isSeat:
                cmp             rbx, 0
                jne             checkSeats_loop
                mov             byte ptr [rdx], '#'
                jmp             checkSeats_loop
checkSeats_finished:
                ret
# ------------------------------------------------------------- #
# update each seat (count number of seats)
updatedSeats:
                lea             rdi, [answerBuffer + RIP]
                lea             rdx, [checkBuffer + RIP]
                xor             rax, rax
                jmp             updatedSeats_start
updatedSeats_loop:
                inc             rdi
                inc             rdx
updatedSeats_start:
                cmp             byte ptr [rdi], 0
                je              updatedSeats_finished

                cmp             byte ptr [rdi], '.'
                je              updatedSeats_loop

updatedSeats_update:
                mov             bl, byte ptr [rdx]
                mov             byte ptr [rdi], bl

                cmp             bl, '#'
                jne             updatedSeats_loop
                inc             rax
                jmp             updatedSeats_loop
updatedSeats_finished:
                ret