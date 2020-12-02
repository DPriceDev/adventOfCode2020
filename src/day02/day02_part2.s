
.global _main

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4

# Local Variables
.bss
fileBuffer:     .lcomm          fbuffer, 24000
lineBuffer:     .lcomm          lbuffer, 64
numberBuffer:   .lcomm          nbuffer, 12

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
                mov             rdx, 24000                      # number of bytes to read
                syscall

                # Close a file
                mov             rdi, [fileDescriptor + RIP]     # file descriptor of the opened file
                call            closefile

# ------------------------------------------------------------- #

                # split buffer into lines and convert to integer, then push to stack
                lea             rdx, [fileBuffer + RIP]         # buffer to split
splitLoop:
                lea             rdi, [lineBuffer + RIP]         # line output buffer
                call            splitString

                # Check a password
                push            rdx                             # Save the input file buffer
                lea             rdi, [lineBuffer + RIP]         # mov line buffer to rdi to check password
                call            checkPassword
                pop             rdx                             # restore input file buffer

                # Split again if buffer not finished
                cmp             byte ptr [rdx], 0               # if null terminator is not reached, split again
                jne             splitLoop

                # Print Number of valid passwords
                mov             rax, r9                         # move the count to rax and print result
                call            printInteger

                # Exit
                call            exit

# ------------------------------------------------------------- #
# Check the password is correct
checkPassword:
                # get first number
                call            findNumber                      # find first number
                mov             r10, rax                        # save number into register r10

                # get next number
                call            findNumber                      # find second number
                mov             r11, rax                        # save number into register r11

                # find character
                mov             rax, 'a'
                mov             rsi, 'z'
                call            findCharacterInRange            # find character to check for
                mov             r12, [rdi]                      # save character into r12

                # proceed to beginning of the password string
                inc             rdi                             # Skip over character to check for
                call            findCharacterInRange            # find first character of the password

                # check characters in the password are correct
                call            comparePassword

                cmp             rax, 0                          # check if count is less than lower limit
                je              checkPassword_notViable

                inc             r9                              # increment the file count if in range
checkPassword_notViable:
                ret

# ------------------------------------------------------------- #
# Extract a number from a string
findNumber:
                lea             rdx, [numberBuffer + RIP]       # set rdx to be the number buffer

                mov             rax, '0'
                mov             rsi, '9'
                call            findCharacterInRange            # find the first occuring number in the string

findNumber_nextChar:
                mov             rsi, [rdi]                      # move value from pointer to pointer
                mov             [rdx], rsi

                inc             rdi                             # increment string buffer
                inc             rdx                             # increment number buffer

                cmp             byte ptr [rdi], '0'             # if char is less than 0
                jl              findNumber_finished

                cmp             byte ptr [rdi], '9'             # if char is greater than 9
                jg              findNumber_finished

                jmp             findNumber_nextChar             # check the next char

findNumber_finished:
                mov             byte ptr [rdx], 0               # set last char as a null terminator
                lea             rsi, [numberBuffer + RIP]       # set rsi as the number buffer for stringToInt
                call            stringToInt                     # convert the string to an int

                ret

# ------------------------------------------------------------- #
# check if one or the other positions contains the required character, but not both or neither.
comparePassword:
                xor             rax, rax                        # clear r13 to a null terminator

                cmp             byte ptr [rdi + r10 - 1], r12b  # check if char at position r10 - 1 is equal
                jne             comparePassword_secondCheck

                cmp             byte ptr [rdi + r11 - 1], r12b  # check if char at position r11 - 1 is equal
                je              comparePassword_finish

                mov             rax, 1                          # if the first is equal and not the other, set true
                jmp             comparePassword_finish

comparePassword_secondCheck:
                cmp             byte ptr [rdi + r11 - 1], r12b  # check if the second number is equal
                jne             comparePassword_finish
                mov             rax, 1                          # if the first is equal and not the other, set true
comparePassword_finish:
                ret