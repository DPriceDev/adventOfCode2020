
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

multiplyLoop:
                xor             rax, rax

                push            rax
                lea             rdx, [fileBuffer + RIP]         # Move rdx to start of input buffer
                mov             r11, 1
                mov             r12, 1
                call            checkTrees

                mov             rax, r9

                push            rax
                lea             rdx, [fileBuffer + RIP]         # Move rdx to start of input buffer
                mov             r11, 3
                mov             r12, 1
                call            checkTrees
                pop             rax

                xor             rdx, rdx
                mul             r9

                push            rax
                lea             rdx, [fileBuffer + RIP]         # Move rdx to start of input buffer
                mov             r11, 5
                mov             r12, 1
                call            checkTrees
                pop             rax

                xor             rdx, rdx
                mul             r9

                push            rax
                lea             rdx, [fileBuffer + RIP]         # Move rdx to start of input buffer
                mov             r11, 7
                mov             r12, 1
                call            checkTrees
                pop             rax

                xor             rdx, rdx
                mul             r9

                push            rax
                lea             rdx, [fileBuffer + RIP]         # Move rdx to start of input buffer
                mov             r11, 1
                mov             r12, 2
                call            checkTrees
                pop             rax

                xor             rdx, rdx
                mul             r9

                call            printLnInteger


                # Exit
                call            exit

# ------------------------------------------------------------- #
# input rdx, pointer to buffer
checkTrees:
                push            r10

                mov             r9, r10
                mov             rsi, r10

                # calculate rows to jump
                push            rax
                push            rdx

                xor             rdx, rdx
                inc             r10

                mov             rax, r10
                mul             r12

                mov             r10, rax

                pop             rdx
                pop             rax

                mov             r8, r10                         # save column offset in r8

                # calculate the line offset
                add             r10, r11

                # calculate the check buffer i.e. 32 - 5~
                mov             rax, r11
                add             r11, r12                        # add the number of new lines to offset by
                inc             rax                             # calculate back off from line end

                # add row offset to r11
                mov             r11, r10
                sub             r11, r8
                add             r11, r12                        # add the number of new lines to offset by

                # clear buffers
                mov             r12, r9
                inc             r12
                xor             r9, r9                          # clear r9

scanningLoop:
                #
                mov             r13, r12
                sub             r13, rax                        # subtract 5 from the current line end count

                #
                mov             r14, rdx                        # copy the current buffer position
                lea             r15, [fileBuffer + RIP]         # copy the start of the input buffer
                sub             r14, r15                        # get length of rdx from start

                # increment lines and line count
                add             r12, r8                         # increment line counter
                add             rdx, r10                        # add a line length + offset r11

                # check if a line was lost due to end of line
                cmp             r14, r13                        # check if that is close to the end of a line
                jl              checkChar
                sub             rdx, rsi

checkChar:
                push            r11
                push            r10
                push            r8
                push            rax
                push            rsi
                mov             rsi, rdx
                call            printChar                       # DEBUG
                pop             rsi
                pop             rax
                pop             r8
                pop             r10
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
                pop             r10

                ret