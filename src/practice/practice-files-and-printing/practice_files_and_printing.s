
.global _main

# --------------------------------------------- #
# Variables
.data
message:        .ascii          "Hello, world\n"
fileName:       .asciz          "testOutput.txt"
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4

positiveString: .asciz          "12345"
negativeString: .asciz          "-34231"

positiveNum:    .quad           0
negativeNum:    .quad           0

.bss
memory:         .lcomm          buffer, 32

# --------------------------------------------- #
# Main
.text
_main:
                # Open a file
                lea             rdi, [fileName + RIP]           # move address of filename string to rdi
                call            openfile
                mov [fileDescriptor + RIP], rax                 # save returned file descriptor

                # Write Hello World to a file
                mov             rdi, [fileDescriptor + RIP]     # file descriptor of the opened file
                lea             rsi, [message + RIP]            # address of hello world
                mov             rdx, 13                         # length of hello world
                call            writefile

                # Close a file
                mov             rdi, [fileDescriptor + RIP]     # file descriptor of the opened file
                call            closefile

                # Open the inputs file
                lea             rdi, [inputsFileName + RIP]     # move address of filename string to rdi
                call            openfile
                mov             [fileDescriptor + RIP], rax     # save returned file descriptor

                # Read the inputs.txt file
                mov             rax, [syscall_read + RIP]       # invoke SYS_READ (kernel opcode 3)
                mov             rdi, [fileDescriptor + RIP]     # move the opened file descriptor into EBX
                lea             rsi, [memory + RIP]             # move the memory address of our file contents variable into ecx
                mov             rdx, 15                         # number of bytes to read - one for each letter of the file contents
                syscall

                # Close a file
                mov             rdi, [fileDescriptor + RIP]     # file descriptor of the opened file
                call            closefile

                # print a string to the console
                lea             rsi, [memory + RIP]
                call            printLnString

                # Get the length of the string
                lea             rsi, [memory + RIP]
                call            stringLength

                call            printNewLine

                # print the length of the integer
                mov             rax, 0
                call            printLnInteger

                # convert a string to an integer
                lea             rsi, [positiveString + RIP]
                call            stringToInt
                call            printLnInteger

                # convert a string to a negative integer
                lea             rsi, [negativeString + RIP]
                call            stringToInt
                call            printLnInteger

                # Exit
                call            exit