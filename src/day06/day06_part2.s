
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
                // New macro way of opening a file, reading it to the buffer, then closing it.
                oftb            [inputsFileName + RIP], [fileBuffer + RIP], [fileSize + RIP]
# ------------------------------------------------------------- #
                lea             rdx, [fileBuffer + RIP]
                xor             r11, r11
splitLoop:
                cmp             byte ptr [rdx], 0               // check for null, finished when no more lines
                je              finished

                // New macro way of spliting a string by a token
                ssbt            [lineBuffer + RIP], [splitToken + RIP]

                push            r11
                call            countAnswers                    // count number of answered questions
                pop             r11

                add             r11, rax                        // accumalate sum
                jmp             splitLoop
finished:
                mov             rax, r11
                call            printInteger                    // print result
                call            exit

# ------------------------------------------------------------- #
countAnswers:
                xor             rax, rax
                mov             r12, 1                          // set number of lines to 1
                jmp             countAnswers_start
countAnswers_line:
                inc             r12                             // increment number of lines
countAnswers_increment:
                inc             rdi
countAnswers_start:
                cmp             byte ptr [rdi], 0               // Finish when at end of string
                je              countAnswers_finished
                cmp             byte ptr [rdi], '\n'            // Count number of lines
                je              countAnswers_line

                xor             rax, rax                        // Clear buffer, get the char and convert to position
                mov             al, byte ptr [rdi]
                sub             rax, 97

                lea             rbx, [answerBuffer + RIP]       // get the answer address and offset by number position
                add             rbx, rax
                add             byte ptr [rbx], 1               // increase count by 1 for specific character

                jmp             countAnswers_increment
countAnswers_finished:
                lea             rbx, [answerBuffer + RIP]
                xor             rax, rax
                xor             rcx, rcx
countAnswers_count:
                cmp             byte ptr [rbx], r12b            // compare the number of lines to the count of a character
                jne             countAnswers_countContinue
                inc             rax                             // increment if equal (everyone has this character)

countAnswers_countContinue:
                mov             byte ptr [rbx], 0               // reset the count to zero for this character
                inc             rbx                             // move to next character
                inc             rcx

                cmp             rcx, 26                         // if all letters counted, the finish
                jl              countAnswers_count
                ret