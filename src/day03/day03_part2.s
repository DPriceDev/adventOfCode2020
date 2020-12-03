
.global _main

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4

rows:           .int            1, 3, 5, 7, 1
columns:        .int            1, 1, 1, 1, 2

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
                mov             r10, rax                        # store length of first row

# ------------------------------------------------------------- #
                # Setup loop variables
                mov             rax, 1                          # set rax to 1 as a base multiple
                mov             rbx, 5                          # Set loop of pairs counter to number of pairs
                lea             rdi, [rows + RIP]               # set r14 and 415 to the row and columns addresses
                lea             rcx, [columns + RIP]

                # Loop through each set and find total
multiplyLoop:
                # get row and column values
                mov             r11w, [rdi]                     # row, move a word size as only want the integer
                mov             r12w, [rcx]                     # column

                # check trees
                lea             rsi, [fileBuffer + RIP]         # Move rdx to start of input buffer
                call            checkTrees                      # check the number of trees with these steps, result in r9

                # multiply result
                xor             rdx, rdx                        # clear rdx for the multiplication
                mul             r9                              # multiply the current running total in rax by the number of trees in r9

                # decrement loop and go to next variable
                dec             rbx                             # decrease loop count
                add             rdi, 4                          # increment to the next integer (4 bytes/addresses)
                add             rcx, 4

                # loop check
                cmp             rbx, 0                          # loop if not finished
                jne             multiplyLoop

                # Print multiplication
                call            printLnInteger

                # Exit
                call            exit



# ------------------------------------------------------------- #
# input rdx, pointer to buffer
checkTrees:
                push            rax
                push            rbx
                push            rcx
                push            rsi

                # Clear counter and copy line length
                xor             r9, r9                          # clear r9 as the tree counter
                mov             rcx, r10                        # save original line length in r10
                inc             rcx                             # add one to line length to account for new line char

                # calculate rows offset to jump
                mov             rax, rcx                        # move line length (with nl) to rax
                xor             rdx, rdx                        # clear rdx for multiplication
                mul             r12                             # multiply line length by number of rows to skip down
                mov             rcx, rax                        # update rax with length between desired rows

                mov             r8, rcx                         # save r8 as this length between desired rows

                # calculate tree offset
                add             rcx, r11                        # add tree offset to rows to get total tree to tree distance

                # calculate how close to the end of a line before skipping a row
                mov             rbx, r11
                add             r11, r12
                inc             rbx

                # add row offset to r11
                mov             r11, rcx
                sub             r11, r8
                add             r11, r12                        # add the number of new lines to offset by

                # set inital end of line to be a lines length
                mov             r12, r10                        # move line length to r12
                inc             r12                             # add one to account for new line character

scanningLoop:
                # get the line end position and back off value
                mov             r13, r12                        # move line end count to r13
                sub             r13, rbx                        # subtract 5 from the current line end to get back off

                # Get the current position of the buffer ptr
                mov             r14, rsi                        # copy the current buffer position
                lea             r15, [fileBuffer + RIP]         # copy the start of the input buffer
                sub             r14, r15                        # get length of rdx from start

                # increment lines and line count
                add             r12, r8                         # increment line counter
                add             rsi, rcx                        # add a line length + offset r11

                # check if a line was lost due to end of line
                cmp             r14, r13                        # check if that is close to the end of a line
                jl              checkChar
                sub             rsi, r10                        # if close to the end, a line is skiped, subtract one line length

checkChar:
                # check if the char is null terminator, end if so
                cmp             byte ptr [rsi], 0               # check for null terminator, if is null, finish loop
                je              finished

                # check if the char is a #
                cmp             byte ptr [rsi], '#'             # check for tree, if not a tree, loop again
                jne             scanningLoop

                # increment and check next
                inc             r9                              # increment number of trees
                jmp scanningLoop
finished:

                pop             rsi
                pop             rcx
                pop             rbx
                pop             rax

                ret