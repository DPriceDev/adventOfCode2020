
.global _main

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4

firstNumber:    .quad           0
secondNumber:   .quad           0
thirdNumber:    .quad           0
multiple:       .quad           0
count:          .quad           200

failedMessage:  .asciz          "Failed to find 2020"
foundMessage:   .asciz          "Found 2020 from: "
andMessage:     .asciz          " and "
multipleMessage:.asciz          "The multiple is: "

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
                jmp             checkLoop
popStack:
                pop             rax                             # remove from the stack the redundant value

checkLoop:
                cmp             r9, 0                           # if no inputs left, finish
                jle             failed

                mov             rdx, r9                         # move the currently left input count to rdx
                dec             r9                              # decrease the r9 counter for overall inputs
                mov             rdi, rsp                        # move the stack pointer into rdi

                # loop checking each addition
additionLoop:
                dec             rdx                             # decrement the loop count
                mov             r10, rdx                        # save the second loop count

                cmp             rdx, 0                          # check if zero, if so, jump to check loop
                jle             popStack

                mov             rax, [rsp]                      # mov the value at the stack pointer to rax
                add             rdi, 8                          # decrement the rdi pointer to get the next value
                mov             rsi, [rdi]
                add             rax, rsi                        # add the values at both pointers

                mov             r11, rdi                        # update the second loop pointer

                # Loop through the third set of numbers and check addition
thirdAdditionLoop:
                dec             r10                             # decrement the loop count
                cmp             r10, 0                          # check if zero, if so, jump to check loop
                jle             additionLoop

                add             r11, 8                          # decrement the rdi pointer to get the next value
                mov             r12, rax
                mov             r13, [r11]
                add             r12, r13                        # add the values at both pointers

                cmp             r12, 2020                       # if they do not add to 2020, loop
                jne             thirdAdditionLoop

# ------------------------------------------------------------- #

                # found code
found:
                mov             [firstNumber + RIP], rsi        # save the winning numbers in the variables
                mov             rax, [rsp]
                mov             [secondNumber + RIP], rax
                mov             [thirdNumber + RIP], r13

                mov             rax, [secondNumber + RIP]       # multiply the three numbers together
                mov             rdi, [firstNumber + RIP]
                mul             rdi
                mov             rdi, [thirdNumber + RIP]
                mul             rdi
                mov             [multiple + RIP], rax

                # Print found!
                lea             rsi, [foundMessage + RIP]       # print found
                call            printString

                mov             rax, [firstNumber + RIP]       # print number
                call            printInteger

                lea             rsi, [andMessage + RIP]         # print and
                call            printString

                mov             rax, [secondNumber + RIP]       # print number
                call            printInteger

                lea             rsi, [andMessage + RIP]         # print and
                call            printString

                mov             rax, [thirdNumber + RIP]        # print other number
                call            printLnInteger

                lea             rsi, [multipleMessage + RIP]    # print multiple message
                call            printString

                mov             rax, [multiple + RIP]           # print multiple
                call            printLnInteger

                jmp             finished

failed:
                # Print not found..
                lea             rsi, [failedMessage + RIP]
                call            printString

finished:
                # Exit
                call            exit


