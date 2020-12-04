
.global _main

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4
fileSize:       .quad           24000

groupToken:     .asciz          "\n\n"
passportTokens: .asciz          "byr:", "iyr:", "eyr:", "hgt:", "hcl:", "ecl:", "pid:"

checkFunctions: .quad           checkValidYear, checkValidYear, checkValidYear, checkValidHeight, checkValidHairColour, checkValidEyeColour, checkValidPassportId
upperDateLimit: .quad           2002, 2020, 2030
lowerDateLimit: .quad           1920, 2010, 2020

validEyeColour: .asciz          "amb", "blu", "brn", "gry", "grn", "hzl", "oth"

# Local Variables
.bss
fileBuffer:     .lcomm          fbuffer, 24000
lineBuffer:     .lcomm          lbuffer, 248
convertBuffer:  .lcomm          cbuffer, 24

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
                mov             rdx, [fileSize + RIP]           # number of bytes to read
                syscall

                # Close a file
                mov             rdi, [fileDescriptor + RIP]     # file descriptor of the opened file
                call            closefile

# ------------------------------------------------------------- #
                # split string by the token "\n\n"
                lea             rdx, [fileBuffer + RIP]         # buffer to split
splitLoop:
                lea             rdi, [lineBuffer + RIP]         # line output buffer
                lea             rsi, [groupToken + RIP]         # pointer to token string
                call            splitStringToken

                xor             r10, r10
                lea             r11, [passportTokens + RIP]
                lea             r12, [checkFunctions + RIP]
                jmp             passportCheck

passportCheckLoop:
                inc             r10
                add             r11, 5
                add             r12, 8
passportCheck:
                # scan across the output buffer to find the string token "cid:"
                lea             rdi, [lineBuffer + RIP]         # line output buffer
                mov             rsi, r11
                call            findStringToken

                # check if token is found in string
                cmp             byte ptr [rdi], 0
                je              notFound

                # check the token and value is correct
                call            [r12]

                cmp             rax, 0
                je              notFound

                # have all checks completed
                cmp             r10, 6
                jl              passportCheckLoop

                # valid completed all checks
                inc             r9
notFound:
                # check for terminator, if exists,
                cmp             byte ptr [rdx], 0
                jne             splitLoop
finished:

                # print count
                mov             rax, r9
                call            printInteger

                # Exit
                call            exit

# ------------------------------------------------------------- #
checkValidYear:
                push            rdx
                push            rdi

                # todo: extract to array lib?
                xor             rcx, rcx
                lea             rsi, [convertBuffer + RIP]
checkValidYear_copyLoop:
                mov             rbx, [rdi + rcx]
                mov             byte ptr [rsi], bl
                inc             rcx
                inc             rsi
                cmp             rcx, 4
                jl              checkValidYear_copyLoop

                mov             byte ptr [rsi], 0

                # convert these to an int
                lea             rsi, [convertBuffer + RIP]
                call            stringToInt

                # save to r13 to free rax for boolean flag return
                mov             r13, rax
                xor             rax, rax

                # compare to lower limit
                shl             r10, 3
                lea             rbx, [lowerDateLimit + RIP]
                add             rbx, r10
                cmp             r13d, dword ptr [rbx]
                jl              checkValidYear_invalid

                # compare to upper limit
                lea             rbx, [upperDateLimit + RIP]
                add             rbx, r10
                cmp             r13d, dword ptr [rbx]
                jg              checkValidYear_invalid

                inc             rax
checkValidYear_invalid:
                shr             r10, 3
                pop             rdi
                pop             rdx
                ret

# ------------------------------------------------------------- #
checkValidHeight:
                xor             rax, rax

                inc             rax

                ret

# ------------------------------------------------------------- #
checkValidHairColour:
                xor             rax, rax

                inc             rax

                ret

# ------------------------------------------------------------- #
checkValidEyeColour:
                push            rdi
                xor             rax, rax

checkValidEyeColour_loop:


#                call             splitString



                inc             rax
checkValidEyeColour_invalid:
                pop             rdi
                ret

# ------------------------------------------------------------- #
checkValidPassportId:
                push            rdi
                xor             rax, rax
                xor             rbx, rbx

                cmp             byte ptr [rdi], '0'
                jne             checkValidPassportId_invalid

checkValidPassportId_loop:
                # check to see it is a number
                cmp             byte ptr [rdi], '0'
                jl              checkValidPassportId_invalid

                cmp             byte ptr [rdi], '9'
                jg              checkValidPassportId_invalid
                inc             rbx

                # check to see it is greater than 0
                cmp             rbx, 8
                jl              checkValidPassportId_loop

                inc             rdi
                inc             rax
checkValidPassportId_invalid:
                pop             rdi
                ret