
.global _main

.include "macros.s"

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4
fileSize:       .quad           56000
splitToken:     .asciz          "\n"

.bss
fileBuffer:     .lcomm          fbuffer, 56000
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
                cmp             byte ptr [rdx], 0               // check for null, finished when no more lines
                je              finished

                ssbt            [lineBuffer + RIP], [splitToken + RIP]

                inc             r11
                jmp             splitLoop
finished:
                mov             rax, r11
                call            printInteger                    // print result
                call            exit
