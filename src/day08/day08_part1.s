
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
                lea             rdi, [answerBuffer + RIP]
accumalate_loop:
                inc             r11

                cmp             word ptr [rdi + 12], 0
                jne             finished

                mov             word ptr [rdi + 12], r11w

                // convert string to int // do in parse loop?
                push            rdi
                add             rdi, 5
                mov             rsi, rdi
                call            stringToInt
                pop             rdi
jmp:
                cmp             byte ptr [rdi], 'j'
                jne             acc
                call            jump
                jmp             accumalate_loop
acc:
                cmp             byte ptr [rdi], 'a'
                jne             nop
                call            accumalate
nop:
                add             rdi, 16
                jmp             accumalate_loop
finished:
                mov             rax, r12
                call            printInteger                    // print result
                call            exit
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