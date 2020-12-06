
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
idBuffer:       .lcomm          ibuffer, 892

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
                cmp             byte ptr [rdx], 0               # check finished parsing file
                je              finished

                /* Get next input line */
                push            r11                             # save r11 register
                lea             rdi, [lineBuffer + RIP]         # line output buffer
                lea             rsi, [splitToken + RIP]         # pointer to new line token string
                call            splitStringToken                # split the string by new lines
                pop             r11                             # restore r11 register

                /* Get the ID from the binary input */
                lea             rdi, [lineBuffer + RIP]         # go to beginning of the line buffer
                call            binaryCheck

                /* save a true false value to its position in the array */
                lea             rsi, [idBuffer + RIP]           # get the start of the id array
                add             rsi, rax                        # offset the array pointer by the id
                mov             byte ptr [rsi], 1               # set the byte to 1 (true)

                /* Compare the current highest to the id, move if higher */
                cmp             rax, r11                        # compare the id to the running highest
                cmovg           r11, rax                        # update r11 when id is higher
                jmp             splitLoop                       # loop back to new input line
finished:
                lea             rsi, [idBuffer + RIP]           # move the id list to rsi and
                call            scanForSeat                     # find the seat

                /* Print result */
                mov             rax, r11                        # print highest ID
                call            printLnInteger
                mov             rax, r12                        # print seat number
                call            printInteger

                /* Exit Program */
                call            exit

# ------------------------------------------------------------- #
binaryCheck:
                mov             r9, 64                          # set the rows bits to be 1000000b
                mov             r10, 4                          # set the rows bits to be 0000100b
                xor             rax, rax                        # clear registers
                xor             rbx, rbx
binaryCheck_loop:
                cmp             byte ptr [rdi], 'B'             # check for B
                je              binaryCheck_B
                cmp             byte ptr [rdi], 'F'             # check for F
                je              binaryCheck_F
                cmp             byte ptr [rdi], 'R'             # check for R
                je              binaryCheck_R
                cmp             byte ptr [rdi], 'L'             # check for L
                je              binaryCheck_L
                jmp             binaryCheckLoop_finished        # when none of these, finished the row
binaryCheck_B:
                add             rax, r9                         # when higher column (B) add the bit value
binaryCheck_F:
                shr             r9                              # shift the register i.e. 1000000b -> 0100000b
                jmp             binaryCheck_increment
binaryCheck_R:
                add             rbx, r10                        # when higher column (B) add the bit value
binaryCheck_L:
                shr             r10                             # shift the register i.e. 0000100b -> 0000010b
binaryCheck_increment:
                inc             rdi                             # move to next char in line
                jmp             binaryCheck_loop
binaryCheckLoop_finished:
                shl             rax, 3                          # multiply by 8
                add             rax, rbx                        # add the column
                ret

# ------------------------------------------------------------- #
scanForSeat:
                lea             rcx, [idBuffer + RIP]           # check if the end of the array is reached
                add             rcx, r11
                jmp             scanForSeat_start
scanForSeat_loop:
                inc             rsi                             # move to next array location
scanForSeat_start:
                cmp             rsi, rcx                        # check end of the array is reached
                jge             scanForSeat_finished
                cmp             byte ptr [rsi], 0               # check this byte is false
                jne             scanForSeat_loop
                cmp             byte ptr [rsi - 1], 0           # check previous byte is true
                je              scanForSeat_loop

scanForSeat_finished:
                mov             r12, rsi                        # save the current address position
                lea             rsi, [idBuffer + RIP]           # get the start address
                sub             r12, rsi                        # subtract to get the id number
                ret