
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

                xor             r10, r10
                lea             r11, [passportTokens + RIP]
                sub             r11, 5
passportCheckLoop:
                inc             r10
                add             r11, 5

                # scan across the output buffer to find the string token "cid:"
                lea             rdi, [lineBuffer + RIP]         # line output buffer
                mov             rsi, r11
                call            findStringToken

                # check if token is found in string
                cmp             byte ptr [rdi], 0
                je              notFound

                cmp             r10, 7
                jl              passportCheckLoop

                inc             r9
notFound:
                # check for terminator, if exists,
                cmp             byte ptr [rdx], 0
                jne             splitLoop
finished:

                # print count
                mov             rax, r9
                call            printInteger

                # Exit
                call            exit