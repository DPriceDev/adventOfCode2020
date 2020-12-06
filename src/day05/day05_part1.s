
.global _main

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4
fileSize:       .quad           24000
splitToken:     .asciz          "\n"

.bss
fileBuffer:     .lcomm          fbuffer, 24000
lineBuffer:     .lcomm          lbuffer, 24

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

                push            r11
                lea             rdi, [lineBuffer + RIP]         # line output buffer
                lea             rsi, [splitToken + RIP]         # pointer to token string
                call            splitStringToken
                lea             rdi, [lineBuffer + RIP]
                pop             r11

                # setup values
                mov             r9, 64
                mov             r10, 4
                xor             rax, rax
                xor             rbx, rbx
binaryCheckLoop:
                // F sets the binary value to 1
                cmp             byte ptr [rdi], 'B'
                je              binaryCheck_B

                // B sets the binary value to 0
                cmp             byte ptr [rdi], 'F'
                je              binaryCheck_F

                // R sets the binary value to 1
                cmp             byte ptr [rdi], 'R'
                je              binaryCheck_R

                // L sets the binary value to 0
                cmp             byte ptr [rdi], 'L'
                je              binaryCheck_L

                jmp             binaryCheckLoop_finished
binaryCheck_B:
                add             rax, r9
binaryCheck_F:
                shr             r9
                jmp             binaryCheck_increment
binaryCheck_R:
                add             rbx, r10
binaryCheck_L:
                shr             r10

binaryCheck_increment:
                inc             rdi
                jmp             binaryCheckLoop
binaryCheckLoop_finished:
                // on row completion, multiply row and column
                shl             rax, 3
                add             rax, rbx

                // compare to current highest, replace if higher
                cmp             r11, rax
                jge             splitLoop

                mov             r11, rax

                jmp             splitLoop

finished:
                // finished
                mov             rax, r11
                call            printInteger

                # Exit
                call            exit