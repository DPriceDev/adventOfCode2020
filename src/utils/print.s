
.global printString
.global printLnString
.global printLnString
.global printChar
.global printInteger
.global printLnInteger
.global printNewLine

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
                push            rdi
                push            rax
                push            rdx

                mov             rdi, 1
                call            stringLength
                mov             rdx, rax
                call            writefile
                call            printNewLine

                pop             rdx
                pop             rax
                pop             rdi
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
                push            '\n'

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

                xor             rdi, rdi
                cmp             rax, 0                          # if it is zero or higher, jump to division
                jge             printInteger_divide

                push            rax
                push            45
                mov             rsi, rsp
                call            printChar                       # print the character "-"
                pop             rsi
                pop             rax

                sub             rax, 1                          # change from negative to positive
                not             rax

printInteger_divide:
                inc             rdi                             # increment the size counter
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
                cmp             rdi, 0
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