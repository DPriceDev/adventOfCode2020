
.global _main

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4

# Local Variables
.bss
fileBuffer:     .lcomm          fbuffer, 12000
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
                mov             rdx, 12000                      # number of bytes to read
                syscall

                # Close a file
                mov             rdi, [fileDescriptor + RIP]     # file descriptor of the opened file
                call            closefile

# ------------------------------------------------------------- #

                # split buffer into lines and convert to integer, then push to stack
                lea             rdx, [fileBuffer + RIP]         # buffer to split

                # Get first row
                lea             rdi, [lineBuffer + RIP]         # line output buffer
                call            splitString

                # Get length of that row
                lea             rsi,  [lineBuffer + RIP]
                call            stringLength
                mov             r10, rax

                lea             rdx, [fileBuffer + RIP]         # Move rdx to start of input buffer
                mov             r11, 3
                call            checkTrees

                # print result
                mov             rax, r9
                call            printInteger

                # Exit
                call            exit

# ------------------------------------------------------------- #
# input rdx, pointer to buffer
checkTrees:
                # work out the offset, line length + 3 + nl

                mov             rdi, r10        # copy line length, could push

                # setup line offset

                inc             r11
                add             rdi, r11

                mov             rax, r11
                inc             rax

                xor             r9, r9                          # clear r9
                xor             r12, r12                        # clear r12
                mov             r13, rax                        # setup r13 with an offset of 5 to be subtracted on first loop
scanningLoop:
                add             r12, 32                        # increment line counter
                mov             r13, r12
                sub             r13, rax                        # subtract 5 from the current line end count

                mov             r14, rdx                        # copy the current buffer position
                lea             r15, [fileBuffer + RIP]         # copy the start of the input buffer
                sub             r14, r15                        # get length of rdx from start

                cmp             r14, r13                        # check if that is close to the end of a line
                jle             addOffset

                add             rdx, r11                          # if close to a line end, only add 4

                jmp             checkChar
addOffset:
                # add this offset to the file array pointer
                add             rdx, rdi                        # add a line length + 4
checkChar:
                push            r11
                push            r15
                push            rax
                mov             rsi, rdx
                call            printChar                       # DEBUG
                pop             rax
                pop             r15
                pop             r11

                # check if the char is null terminator, end if so
                cmp             byte ptr [rdx], 0               # check for null terminator, if is null, finish loop
                je              finished

                # check if the char is a #
                cmp             byte ptr [rdx], '#'             # check for tree, if not a tree, loop again
                jne             scanningLoop

                # increment and check next
                inc             r9
                jmp scanningLoop
finished:
                ret