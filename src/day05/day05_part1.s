
.global _main

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4
fileSize:       .quad           24000

groupToken:     .asciz          "\n\n"
passportTokens: .asciz          "byr:", "iyr:", "eyr:", "hgt:", "hcl:", "ecl:", "pid:"

# Local Variables
.bss
fileBuffer:     .lcomm          fbuffer, 24000
lineBuffer:     .lcomm          lbuffer, 248

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
                # split string by the token "\n\n"
                lea             rdx, [fileBuffer + RIP]         # buffer to split
splitLoop:
                lea             rdi, [lineBuffer + RIP]         # line output buffer
                lea             rsi, [groupToken + RIP]         # pointer to token string
                call            splitStringToken

                // use string

                # check for terminator in file buffer
                cmp             byte ptr [rdx], 0
                jne             splitLoop

                // finished

                # Exit
                call            exit