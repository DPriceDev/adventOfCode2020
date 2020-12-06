
.global _main

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
                # open the file and save descriptor
                lea             rdi, [inputsFileName + RIP]     # move address of filename string to rdi
                call            openfile
                mov             [fileDescriptor + RIP], rax     # save returned file descriptor

                # read the file to the buffer
                mov             rax, [syscall_read + RIP]       # set sys call as read
                mov             rdi, [fileDescriptor + RIP]     # file descriptor
                lea             rsi, [fileBuffer + RIP]         # pointer to file buffer
                mov             rdx, [fileSize + RIP]           # number of bytes to read
                syscall

                # Close a file
                mov             rdi, [fileDescriptor + RIP]     # file descriptor of the opened file
                call            closefile

# ------------------------------------------------------------- #
                lea             rdx, [fileBuffer + RIP]         # buffer to split
                xor             r11, r11
splitLoop:
                cmp             byte ptr [rdx], 0
                je              finished

                lea             rdi, [lineBuffer + RIP]         # line output buffer
                lea             rsi, [splitToken + RIP]         # pointer to token string
                call            splitStringToken
                lea             rdi, [lineBuffer + RIP]

                push            rdi
                push            r11
                call            countAnswers
                pop             r11
                pop             rdi

                add             r11, rax
                jmp             splitLoop
finished:
                /* finished */
                mov             rax, r11
                call            printInteger

                /* Exit */
                call            exit

# ------------------------------------------------------------- #
countAnswers:
                xor             rax, rax
                jmp             countAnswers_start
countAnswers_increment:
                inc             rdi
countAnswers_start:
                // check for null terminator
                cmp             byte ptr [rdi], 0
                je              countAnswers_finished

                // check for new line
                cmp             byte ptr [rdi], '\n'
                je              countAnswers_increment

                xor             rax, rax
                mov             al, byte ptr [rdi]
                sub             rax, 97

                lea             rbx, [answerBuffer + RIP]
                add             rbx, rax
                mov             byte ptr [rbx], 1

                jmp             countAnswers_increment
countAnswers_finished:
                lea             rbx, [answerBuffer + RIP]
                xor             rax, rax
                xor             rcx, rcx
countAnswers_count:
                add             al, byte ptr [rbx]
                mov             byte ptr [rbx], 0
                inc             rbx
                inc             rcx

                cmp             rcx, 26
                jl              countAnswers_count

                ret