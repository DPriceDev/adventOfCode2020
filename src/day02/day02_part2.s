
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
                lea             rdi, [lineBuffer + RIP]         # line output buffer
splitLoop:
                call            splitString

                push            rdx
                lea             rdi, [lineBuffer + RIP]         # line output buffer
                call            checkPassword

                lea             rdi, [lineBuffer + RIP]         # line output buffer
                pop             rdx

                cmp             byte ptr [rdx], 0               # if null terminator is not reached, split again
                jne             splitLoop

                mov             rax, r9
                call            printInteger

                # Exit
                call            exit

# ------------------------------------------------------------- #

checkPassword:
                # get first number
                call            findNumber
                mov             r10, rax

                # get next number
                call            findNumber
                mov             r11, rax

                # find character
                call            findCharacter
                mov             r12, [rdi]

                # proceed to beginning of the password string
                inc             rdi
                call            findCharacter
                #dec             rdi

                # search character
                xor             r13, r13
                xor             r14, r14
                call            comparePassword

                cmp             r13, r10
                jl              notViable

                cmp             r13, r11
                jg              notViable

                inc             r9                              # increment the file count

notViable:
                ret

# ------------------------------------------------------------- #

findNumber:
                lea             rdx, [numberBuffer + RIP]       # set number buffer
                jmp             startLookingNum
nextNum:
                inc             rdi                             # increment the input buffer
startLookingNum:
                cmp             byte ptr [rdi], 48
                jl              nextNum

                cmp             byte ptr [rdi], 57
                jg              nextNum
saveNumber:
                mov             rsi, [rdi]
                mov             [rdx], rsi

                inc             rdi
                inc             rdx

                cmp             byte ptr [rdi], 48
                jl              found

                cmp             byte ptr [rdi], 57
                jg              found

                jmp             saveNumber
found:
                mov             byte ptr [rdx], 0


                lea             rsi, [numberBuffer + RIP]
                call            stringToInt

                ret

# ------------------------------------------------------------- #

findCharacter:
                jmp             startLookingChar
nextChar:
                inc             rdi                             # increment the input buffer
startLookingChar:
                cmp             byte ptr [rdi], 65
                jl              nextChar

                cmp             byte ptr [rdi], 122
                jg              nextChar

                ret

# ------------------------------------------------------------- #

countCharacters_loop:
                inc             rdi
                inc             r14
countCharacters:

                # finish if string is ended
                cmp             byte ptr [rdi], 0
                je              finished

                # check the lowest b of rax against the saved byte r12
                mov             rax, r12
                cmp             byte ptr [rdi], al
                jne             countCharacters_loop

                inc             r13
                jmp             countCharacters_loop
finished:
                ret

# ------------------------------------------------------------- #

comparePassword:
                # r10
                # r11
                # char r12
                # rdi is array

                # finish if string is ended

                mov             rax, r12

                cmp             byte ptr [rdi + r10 - 1], al
                jne secondCheck

                cmp             byte ptr [rdi + r11 - 1], al
                je incorrect

                mov             r13, r11
                jmp             correct

secondCheck:
                cmp             byte ptr [rdi + r11 - 1], al
                jne incorrect

                mov             r13, r11
                jmp             correct

incorrect:
                mov             r13, 0
correct:
                ret