
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
                mov             rax, [syscall_read + RIP]       # invoke SYS_READ (kernel opcode 3)
                mov             rdi, [fileDescriptor + RIP]     # move the opened file descriptor into EBX
                lea             rsi, [fileBuffer + RIP]         # move the memory address of our file contents variable into ecx
                mov             rdx, 24000                      # number of bytes to read - one for each letter of the file contents
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

checkPassword:

                # get first number
                call            findNumber                      # find first number
                mov             r10, rax                        # save number into register r10

                # get next number
                call            findNumber                      # find second number
                mov             r11, rax                        # save number into register r11

                # find character
                mov             rax, 65
                mov             rsi, 122
                call            findCharacter                   # find character to check for
                mov             r12, [rdi]                      # save character into r12

                # search character
                call            findCharacter                   # find first character of the password
                call            countCharacters                 # count number of characters in string

                cmp             rax, r10                        # check if count is less than lower limit
                jl              checkPassword_notViable

                cmp             rax, r11                        # check if count is higher than upper limit
                jg              checkPassword_notViable

                inc             r9                              # increment the file count if in range
checkPassword_notViable:
                ret

# ------------------------------------------------------------- #
# Extract a number from a string
findNumber:
                lea             rdx, [numberBuffer + RIP]       # set rdx to be the number buffer

                mov             rax, 48
                mov             rsi, 57
                call            findCharacter                   # find the first occuring number in the string

findNumber_nextChar:
                mov             rsi, [rdi]                      # move value from pointer to pointer
                mov             [rdx], rsi

                inc             rdi                             # increment string buffer
                inc             rdx                             # increment number buffer

                cmp             byte ptr [rdi], 48              # if char is less than 0
                jl              findNumber_finished

                cmp             byte ptr [rdi], 57              # if char is greater than 9
                jg              findNumber_finished

                jmp             findNumber_nextChar             # check the next char

findNumber_finished:
                mov             byte ptr [rdx], 0               # set last char as a null terminator
                lea             rsi, [numberBuffer + RIP]       # set rsi as the number buffer for stringToInt
                call            stringToInt                     # convert the string to an int

                ret

# ------------------------------------------------------------- #
findCharacter_nextChar:
                inc             rdi                             # increment the input buffer
findCharacter:
                cmp             byte ptr [rdi], al              # check against upper char range
                jl              findCharacter_nextChar

                cmp             byte ptr [rdi], sil             # check against lower char range
                jg              findCharacter_nextChar

                ret

# ------------------------------------------------------------- #
countCharacters:
                xor             rax, rax                        # clear counter
countCharacters_nextChar:
                inc             rdi
countCharacters_start:
                cmp             byte ptr [rdi], 0               # check if end of string
                je              countCharacters_finished

                cmp             byte ptr [rdi], r12b            # compare rdi char to the char in r12
                jne             countCharacters_nextChar

                inc             rax                             # increment if character is found
                jmp             countCharacters_nextChar
countCharacters_finished:
                ret