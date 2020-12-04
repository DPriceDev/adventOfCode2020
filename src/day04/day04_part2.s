
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
                push            rdi
                push            rdx
                push            r10
                push            r12
                call            [r12]
                pop             r12
                pop             r10
                pop             rdx
                pop             rdi

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
                ret

# ------------------------------------------------------------- #
checkValidHeight:
                xor             rax, rax

                mov             rbx, rdi
                lea             rcx, [convertBuffer + RIP]
checkValidHeight_loop:
                mov             r10, [rbx]
                mov             byte ptr [rcx], r10b

                cmp             byte ptr [rcx], 'i'
                je              checkValidHeight_inch

                cmp             byte ptr [rcx], 'c'
                je              checkValidHeight_cm

                cmp             byte ptr [rcx], '0'
                jl              checkValidHeight_invalid

                cmp             byte ptr [rcx], '9'
                jg              checkValidHeight_invalid

                inc             rbx
                inc             rcx
                jmp             checkValidHeight_loop

checkValidHeight_cm:
                mov             byte ptr [rcx], 0
                lea             rsi, [convertBuffer + RIP]
                call            stringToInt

                # compare to upper limit
                cmp             rax, 193
                jg              checkValidHeight_invalid

                # compare to lower limit
                cmp             rax, 150
                jl              checkValidHeight_invalid
                jmp             checkValidHeight_valid

checkValidHeight_inch:
                mov             byte ptr [rcx], 0

                lea             rsi, [convertBuffer + RIP]
                call            stringToInt

                # compare to upper limit
                cmp             rax, 76
                jg              checkValidHeight_invalid

                # compare to lower limit
                cmp             rax, 59
                jl              checkValidHeight_invalid

checkValidHeight_valid:
                mov             rax, 1
                ret
checkValidHeight_invalid:
                xor             rax, rax
                ret

# ------------------------------------------------------------- #
checkValidEyeColour:
                xor             rax, rax
                xor             rbx, rbx

                lea             rdx, [validEyeColour + RIP]
                jmp             checkValidEyeColour_start
checkValidEyeColour_loop:
                inc             rbx
                lea             rdx, [validEyeColour + RIP]
                shl             rbx, 2
                add             rdx, rbx
                shr             rbx, 2
checkValidEyeColour_start:
                # check array finished
                cmp             rbx, 7
                je              checkValidEyeColour_invalid

                # check 1st chars match
                mov             rcx, [rdx]
                cmp             byte ptr [rdi], cl
                jne             checkValidEyeColour_loop

                # check 2nd chars match
                mov             rcx, [rdx + 1]
                cmp             byte ptr [rdi + 1], cl
                jne             checkValidEyeColour_loop

                # check 3rd chars match
                mov             rcx, [rdx + 2]
                cmp             byte ptr [rdi + 2], cl
                jne             checkValidEyeColour_loop

                inc             rax
checkValidEyeColour_invalid:
                ret

# ------------------------------------------------------------- #
checkValidHairColour:
                xor             rax, rax
                xor             rbx, rbx

                cmp             byte ptr [rdi], '#'
                jne             checkValidHairColour_invalid
                inc             rdi

checkValidHairColour_loop:
                # check to see it is a number
                cmp             byte ptr [rdi], '0'
                jl              checkValidHairColour_invalid

                cmp             byte ptr [rdi], '9'
                jle             checkValidHairColour_validChar

                cmp             byte ptr [rdi], 'a'
                jl              checkValidHairColour_invalid

                cmp             byte ptr [rdi], 'z'
                jg              checkValidHairColour_invalid

checkValidHairColour_validChar:
                inc             rbx
                inc             rdi

                # check to see it is greater than 0
                cmp             rbx, 6
                jl              checkValidHairColour_loop

                inc             rax
checkValidHairColour_invalid:
                ret

# ------------------------------------------------------------- #
checkValidPassportId:
                xor             rax, rax
                xor             rbx, rbx

checkValidPassportId_loop:
                # check to see it is a number
                cmp             byte ptr [rdi], '0'
                jl              checkValidPassportId_invalid

                cmp             byte ptr [rdi], '9'
                jg              checkValidPassportId_invalid
                inc             rbx
                inc             rdi

                cmp             rbx, 9
                jl              checkValidPassportId_loop

                cmp             byte ptr [rdi], '0'
                jl              checkValidPassportId_valid

                cmp             byte ptr [rdi], '9'
                jg              checkValidPassportId_valid

                jmp             checkValidPassportId_invalid

checkValidPassportId_valid:
                inc             rax
checkValidPassportId_invalid:
                ret