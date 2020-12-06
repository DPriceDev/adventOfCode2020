
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
lineBuffer:     .lcomm          lbuffer, 32

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


                /* Todo */


finished:
                /* finished */
                mov             rax, r11
                call            printInteger

                /* Exit */
                call            exit