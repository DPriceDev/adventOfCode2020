.include "syscalls.s"

.data
file_mode_RW:   .quad           0x0222

permissions_RW: .quad           0777

.text
# --------------------------------------------- #
# Open or Create a file
# mov           rdi, "file descriptor"
openfile:
                mov             rax, [syscall_open + RIP]
                mov             rsi, [file_mode_RW + RIP]
                mov             rdx, [permissions_RW + RIP]
                syscall
                ret

# --------------------------------------------- #
# close a file
# mov           rdi, "file descriptor"
closefile:
                mov             rax, [syscall_close + RIP]
                syscall
                ret

# --------------------------------------------- #
# write a file
# mov           rdi, "file descriptor"
# lea           rsi, "pointer to buffer"
# mov           rdx, "length of buffer to write"
writefile:
                mov             rax, [syscall_write + RIP]
                syscall
                ret

# --------------------------------------------- #
# exit
exit:
                mov             rax, [syscall_exit + RIP]
                xor             rdi, rdi
                syscall

# --------------------------------------------- #
# print a string to the console
# lea           rsi, "pointer to buffer"
# mov           rdx, "length of buffer to write"
printString:
                mov             rdi, 1
                call            stringLength
                mov             rdx, rax
                call            writefile
                ret

# --------------------------------------------- #
# print a string, with a new line to the console
# lea           rsi, "pointer to buffer"
# mov           rdx, "length of buffer to write"
printLnString:
                mov             rdi, 1
                call            stringLength
                mov             rdx, rax
                call            writefile
                call            printNewLine
                ret

# --------------------------------------------- #
# print a char to the console
# lea           rsi, "pointer to buffer"
printChar:
                push            rdi
                push            rdx

                mov             rdi, 1
                mov             rdx, 1
                call            writefile

                pop             rdx
                pop             rdi
                ret

# --------------------------------------------- #
# print a new line to the console
printNewLine:
                push            rsi
                push            10

                mov             rsi, rsp
                call            printChar

                pop             rsi
                pop             rsi
                ret

# --------------------------------------------- #
# print integer
# mov           rax, "integer"
printInteger:
                push            rax                             # save the current register values
                push            rsi
                push            rdi
                push            rdx

                cmp             rax, 0                          # if it is zero or higher, jump to division
                jge             printInteger_divide

                push            rax
                mov             byte ptr [rsi], 45
                call            printChar                       # print the character "-"
                pop             rax

                sub             rax, 1                          # change from negative to positive
                not             rax

printInteger_divide:
                inc             rdi                             # increment the size of the
                xor             rdx, rdx                        # clear rdx for the divide
                mov             rsi, 10                         # Set rdi as 10 to divide by 10
                idiv            rsi                             # do the divide
                add             rdx, 48                         # convert the result to the char value
                push            rdx                             # push to the stack
                cmp             rax, 0
                jnz             printInteger_divide             # compare the quotient to zero, if zero, then the number is bigger and not finished

printInteger_print:
                dec             rdi                             # decrement rdi
                mov             rsi, rsp                        # mov the stack pointer to the rsi buffer for the print
                call            printChar                       # print the character at the stack pointer
                pop             rax                             # remove the last printed char from the stack
                cmp             rdi, 1
                jnz             printInteger_print              # if rdi is not zero, keep printing

                pop             rdx                             # restore the register values
                pop             rdi
                pop             rsi
                pop             rax

                ret

# --------------------------------------------- #
# print integer, with a new line after
# mov           rax, "integer"
printLnInteger:
                call            printInteger
                call            printNewLine
                ret

# --------------------------------------------- #
# Get String Length
#  todo: investigate "repne scasb"
# mov           rsi, "string buffer"
# return length in rax
stringLength:
                mov             rax, rsi

stringLength_nextChar:
                cmp             byte ptr [rax], 0
                je              stringLength_complete
                inc             rax
                jmp             stringLength_nextChar

stringLength_complete:
                sub             rax, rsi
                ret

# --------------------------------------------- #
# Convert String to Int
# mov           rsi, "string buffer"
# return int in rax
stringToInt:
                push            r9                              # push register to stack to save them
                push            r10
                push            rsi
                push            rdi
                push            rdx

                call            stringLength                    # get the length of the string to convert
                dec             rsi

                lea             r10, [rsi]                      # get the address of the string buffer
                add             r10, rax                        # add the string length as an offset

                mov             rdi, 1                          # set the multiplier value as 1

stringToInt_convert:
                mov             rax, [r10]                      # move the value of the offset pointer to rax

                xor             rdx, rdx                        # clear rdx
                add             dl, al                          # add the bottom byte of rax to rdx
                mov             rax, rdx                        # update rax as rdx, should be the bottom byte only

                cmp             rax, 45                         # if value is a "-", negate the number
                jne             stringToInt_multiply

                not             r9                              # negate the integer
                add             r9, 1

                jmp             stringToInt_finished            # finish after negation

stringToInt_multiply:
                sub             al, 48                          # subtract 48 to convert from ascii to integer
                mul             rdi                             # multiply the integer in rax by the multiplier rdi
                add             r9, rax                         # update total

                mov             rax, rdi
                shl             rax, 2                          # shift rdi, 1... -> 4...
                shl             rdi, 4                          # shift rdi, 1... -> 16...
                sub             rdi, rax                        # 16... - 4... = 12...
                shr             rax                             # 4... -> 2...
                sub             rdi, rax                        # 12... - 2... = 10...

                dec             r10                             # decrement pointer, moving to the next number
                cmp             r10, rsi                        # check if the original buffer pointer is reached
                jne             stringToInt_convert

stringToInt_finished:
                mov             rax, r9                         # put final value into rax

                pop             rdx                             # restore registers
                pop             rdi
                pop             rsi
                pop             r10
                pop             r9

                ret