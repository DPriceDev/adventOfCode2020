
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

# ------------------------------------------------------------- #
# split string with a string token
checkForStartLoop:
                # copy value from the file buffer to the line buffer
                mov             rax, [rdx]
                mov             [rdi], rax

                # increment file buffer to next char
                inc             rdx
                inc             rdi

splitStringToken:
                # check for terminator
                cmp             byte ptr [rdx], 0
                je              finishedSplitting

                # check if the same, if so continue, or loop
                mov             rax, [rsi]
                cmp             byte ptr [rdx], al
                jne             checkForStartLoop

                mov             rbx, rsi                        # save token buffer start address
checkToken:
                # save to buffer
                mov             rax, [rdx]
                mov             [rdi], rax

                # increment count
                inc             rdx
                inc             rdi
                inc             rsi

                # check file buffer nul reached
                cmp             byte ptr [rdx], 0
                je              finishedSplitting

                # check token buffer nul reached
                cmp             byte ptr [rsi], 0
                je              finishedSplitting

                # check matches
                mov             rax, [rsi]
                cmp             byte ptr [rdx], al
                je              checkToken

                # not, reset token buffer and return
                mov             rsi, rbx
                jmp             checkForStartLoop

finishedSplitting:
                # add null terminator to output buffer
                mov             byte ptr [rdi], 0
                ret


# ------------------------------------------------------------- #
# find string token in string
findStringToken_loop:
                inc             rdi
findStringToken:
                # check for terminator
                cmp             byte ptr [rdi], 0
                je              findStringToken_finished

                # check if the same, if so continue, or loop
                mov             rax, [rsi]
                cmp             byte ptr [rdi], al
                jne             findStringToken_loop

                mov             rbx, rsi                        # save token buffer start address
findStringToken_checkToken:
                # increment count
                inc             rdi
                inc             rsi

                # check file buffer nul reached
                cmp             byte ptr [rdi], 0
                je              findStringToken_finished

                # check token buffer nul reache
                cmp             byte ptr [rsi], 0
                je              findStringToken_finished

                # check matches
                mov             rax, [rsi]
                cmp             byte ptr [rdi], al
                je              findStringToken_checkToken

                # not, reset token buffer and return
                mov             rsi, rbx
                jmp             findStringToken_loop

findStringToken_finished:
                ret