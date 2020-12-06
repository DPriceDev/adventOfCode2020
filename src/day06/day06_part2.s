
.global _main

.include "macros.s"

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4
fileSize:       .quad           24000
splitToken:     .asciz          "\n\n"

.bss
fileBuffer:     .lcomm          fbuffer, 24000
lineBuffer:     .lcomm          lbuffer, 128
answerBuffer:   .lcomm          abuffer, 26

# ------------------------------------------------------------- #
# Main
.text
_main:
                oftb            [inputsFileName + RIP], [fileBuffer + RIP], [fileSize + RIP]
# ------------------------------------------------------------- #
                lea             rdx, [fileBuffer + RIP]
                xor             r11, r11
splitLoop:
                cmp             byte ptr [rdx], 0
                je              finished

                ssbt            [lineBuffer + RIP], [splitToken + RIP]

                push            r11
                call            countAnswers
                pop             r11

                add             r11, rax
                jmp             splitLoop
finished:
                mov             rax, r11
                call            printInteger
                call            exit

# ------------------------------------------------------------- #
countAnswers:
                xor             rax, rax
                mov             r12, 1
                jmp             countAnswers_start
countAnswers_line:
                inc             r12
countAnswers_increment:
                inc             rdi
countAnswers_start:
                cmp             byte ptr [rdi], 0
                je              countAnswers_finished
                cmp             byte ptr [rdi], '\n'
                je              countAnswers_line

                xor             rax, rax
                mov             al, byte ptr [rdi]
                sub             rax, 97

                lea             rbx, [answerBuffer + RIP]
                add             rbx, rax
                add             byte ptr [rbx], 1

                jmp             countAnswers_increment
countAnswers_finished:
                lea             rbx, [answerBuffer + RIP]
                xor             rax, rax
                xor             rcx, rcx
countAnswers_count:
                cmp             byte ptr [rbx], r12b
                jne             countAnswers_countContinue
                inc             rax

countAnswers_countContinue:
                mov             byte ptr [rbx], 0
                inc             rbx
                inc             rcx

                cmp             rcx, 26
                jl              countAnswers_count
                ret