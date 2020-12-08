
.global _main

.include "macros.s"

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4
fileSize:       .quad           6000
splitToken:     .asciz          "\n"

.bss
fileBuffer:     .lcomm          fbuffer, 6000
lineBuffer:     .lcomm          lbuffer, 16
answerBuffer:   .lcomm          abuffer, 12000                  // buffer of 8 bytes + 4 empty bytes + integer

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
                je              split_finished

                mov             rdi, rcx
                push            rcx
                lea             rsi, [splitToken + RIP]
                call            splitStringToken
                pop             rcx

                add             rcx, 16
                jmp             splitLoop
split_finished:
                call            searchForInvalidCommand

                mov             rax, r12
                call            printInteger                    // print result
                call            exit

# ------------------------------------------------------------- #
searchForInvalidCommand:
                xor             rcx, rcx
searchForInvalidCommand_loop:
                lea             rdi, [answerBuffer + RIP]
                xor             r11, r11
                xor             r12, r12
accumalate_loop:
                inc             r11

                mov             rsi, rdi
                lea             rbx, [answerBuffer + RIP]
                sub             rsi, rbx

                cmp             rsi, 10000
                jg              accumalate_loopFinished

                cmp             word ptr [rdi + 12], 0
                jne             accumalate_loopFinished

                mov             word ptr [rdi + 12], r11w

                // check if line to change
                cmp             rsi, rcx
                jne             accumalate_noChange

                cmp             byte ptr [rdi], 'n'
                jne             accumalate_changeJmp
                call            jump
                jmp             accumalate_loop
accumalate_changeJmp:
                cmp             byte ptr [rdi], 'j'
                je              accumalate_nop
accumalate_noChange:

                // convert string to int // do in parse loop?
                push            rdi
                add             rdi, 5
                mov             rsi, rdi
                call            stringToInt
                pop             rdi

                cmp             byte ptr [rdi], 'j'
                jne             accumalate_acc
                call            jump
                jmp             accumalate_loop
accumalate_acc:
                cmp             byte ptr [rdi], 'a'
                jne             accumalate_nop
                call            accumalate
accumalate_nop:
                add             rdi, 16
                jmp             accumalate_loop
accumalate_loopFinished:
                // check if rdi is last line
                lea             rbx, [answerBuffer + RIP]
                sub             rdi, rbx
                cmp             rdi, 10000
                je              searchForInvalidCommand_finished

                add             rbx, 12
                xor             r11, r11
clear_loop:
                inc             r11
                mov             word ptr [rbx], 0
                add             rbx, 16
                cmp             r11, 625
                jl              clear_loop

                inc             rcx
                jmp             searchForInvalidCommand_loop
searchForInvalidCommand_finished:
                ret

# ------------------------------------------------------------- #
jump:
                shl             rax, 4
                cmp             byte ptr [rdi + 4], '-'
                jne             jump_add
                sub             rdi, rax
                jmp             jump_finished
jump_add:
                add             rdi, rax
jump_finished:
                ret
# ------------------------------------------------------------- #
accumalate:
                cmp             byte ptr [rdi + 4], '-'
                jne             accumalate_add
                sub             r12, rax
                jmp             accumalate_finished
accumalate_add:
                add             r12, rax
accumalate_finished:
                ret
# ------------------------------------------------------------- #
updateCommand:
                cmp             byte ptr [rdi], 'n'
                jne             updateCommand_jmp
                mov             byte ptr [rdi], 'j'
updateCommand_jmp:
                cmp             byte ptr [rdi], 'j'
                jne             updateCommand_finished
                mov             byte ptr [rdi], 'n'
updateCommand_finished:
                ret