
.global _main

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4
fileSize:       .int            20000

# Local Variables
.bss
fileBuffer:     .lcomm          fbuffer, 20000
lineBuffer:     .lcomm          lbuffer, 64

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

                # Get first row
                lea             rdx, [fileBuffer + RIP]         # buffer to split
                lea             rdi, [lineBuffer + RIP]         # line output buffer
                call            splitString

                # Exit
                call            exit