
.global _main

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4

# Local Variables
.bss
fileBuffer:     .lcomm          fbuffer, 2048
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
                mov             rax, [syscall_read + RIP]       # invoke SYS_READ (kernel opcode 3)
                mov             rdi, [fileDescriptor + RIP]     # move the opened file descriptor into EBX
                lea             rsi, [fileBuffer + RIP]         # move the memory address of our file contents variable into ecx
                mov             rdx, 2048                       # number of bytes to read - one for each letter of the file contents
                syscall

                # Close a file
                mov             rdi, [fileDescriptor + RIP]     # file descriptor of the opened file
                call            closefile

# ------------------------------------------------------------- #

                # split buffer into lines and convert to integer, then push to stack
                lea             rdx, [fileBuffer + RIP]         # buffer to split
                lea             rdi, [lineBuffer + RIP]         # line output buffer
splitLoop:
                call            splitString

                lea             rsi, [lineBuffer + RIP]         # move output line to rsi
                call            stringToInt                     # convert line to an Integer
                push            rax                             # push the integer onto the stack

                inc             r9                              # increment the file count
                lea             rdi, [lineBuffer + RIP]         # line output buffer

                cmp             byte ptr [rdx], 0               # if null terminator is not reached, split again
                jne             splitLoop

# ------------------------------------------------------------- #






                # Exit
                call            exit