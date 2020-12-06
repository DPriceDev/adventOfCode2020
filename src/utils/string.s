
.global splitString
.global splitStringToken
.global stringToInt
.global stringLength
.global findCharacter
.global findCharacterInRange
.global findStringToken

# ------------------------------------------------------------- #
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

# ------------------------------------------------------------- #
# Split a string by a delimiter
# lea           rdx, "input string buffer"
# lea           rdi, "output line buffer"
# mov           rcx, delimiter i.e. ' '
# return        output line or 0 for no more lines into rdi
# return        output last position in the input buffer
splitString:
                push            rax
                push            rsi

                mov             rsi, rdx                        # update moving pointer rsi to match start pointer rdx
                jmp             splitString_inputs              # start splitting
splitString_increment:
                mov             rax, [rsi]
                mov             [rdi], rax
                inc             rdi                             # increment to next char in output buffer
                inc             rsi                             # increment rsi to next char
splitString_inputs:
                cmp             byte ptr [rsi], 0               # end splitting if null char encountered
                je              splitString_zero

                cmp             byte ptr [rsi], 10              # if not a next line, loop
                jne             splitString_increment
splitString_zero:
                mov             byte ptr [rdi], 0

                mov             rdx, rsi                        # offset start point to beginning of next line
                inc             rdx                             # skip over line end char

                pop             rsi
                pop             rax

                ret

# ------------------------------------------------------------- #
# split string with a string token
# lea             rdx, [fileBuffer + RIP]         # buffer to split
# lea             rdi, [lineBuffer + RIP]
# lea             rsi, [groupToken + RIP]

# returns line before split in rdx, including the token
# returns the address after the token in rdx
checkForStartLoop:
                # copy value from the file buffer to the line buffer
                mov             al, byte ptr [rdx]
                mov             byte ptr [rdi], al

                # increment file buffer to next char
                inc             rdx
                inc             rdi

splitStringToken:
                # check for terminator
                cmp             byte ptr [rdx], 0
                je              finishedSplitting

                # check if the same, if so continue, or loop
                mov             rax, [rsi]
                cmp             byte ptr [rdx], al
                jne             checkForStartLoop

                mov             rbx, rsi                        # save token buffer start address
checkToken:
                # save to buffer
                mov             al, byte ptr [rdx]
                mov             byte ptr [rdi], al

                # increment count
                inc             rdx
                inc             rdi
                inc             rsi

                # check file buffer nul reached
                cmp             byte ptr [rdx], 0
                je              finishedSplitting

                # check token buffer nul reached
                cmp             byte ptr [rsi], 0
                je              finishedSplitting

                # check matches
                mov             rax, [rsi]
                cmp             byte ptr [rdx], al
                je              checkToken

                # not, reset token buffer and return
                mov             rsi, rbx
                jmp             checkForStartLoop

finishedSplitting:
                # add null terminator to output buffer
                mov             byte ptr [rdi], 0
                ret


# ------------------------------------------------------------- #
# Convert String to Int
# lea           rsi, "string buffer"
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
                xor             r9, r9

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

# ------------------------------------------------------------- #
# Find First Occurrance of a Character (in a range) in String
#               lea             rdi, buffer - String buffer to check
#               mov             rax, 'a' - lower char limit
#               mov             rsi, 'z' - upper char limit
# return character or terminator in pointer returned in rdi
findCharacterInRange_nextChar:
                inc             rdi                             # increment the input buffer
findCharacterInRange:
                cmp             byte ptr [rdi], 0               # check against lower char range
                jl              findCharacterInRange_terminator

                cmp             byte ptr [rdi], al              # check against lower char range
                jl              findCharacterInRange_nextChar

                cmp             byte ptr [rdi], sil             # check against upper char range
                jg              findCharacterInRange_nextChar
findCharacterInRange_terminator:
                ret

# ------------------------------------------------------------- #
# Find First Occurrance of a Character in String
#               lea             rdi, buffer - String buffer to check
#               mov             rax, 'a' - character to check for
# return character or terminator in pointer returned in rdi
findCharacter_nextChar:
                inc             rdi                             # increment the input buffer
findCharacter:
                cmp             byte ptr [rdi], 0               # check against lower char range
                jl              findCharacter_terminator

                cmp             byte ptr [rdi], al              # check against lower char range
                jl              findCharacter_nextChar
findCharacter_terminator:
                ret


# ------------------------------------------------------------- #
# find string token in string
# lea             rdi, [lineBuffer + RIP]         # line output buffer
# mov             rsi, [token + RIP]              # token
# returns address of token in rdi, or address of the end of the string

findStringToken_loop:
                inc             rdi
findStringToken:
                # check for terminator
                cmp             byte ptr [rdi], 0
                je              findStringToken_finished

                # check if the same, if so continue, or loop
                mov             rax, [rsi]
                cmp             byte ptr [rdi], al
                jne             findStringToken_loop

                mov             rbx, rsi                        # save token buffer start address
findStringToken_checkToken:
                # increment count
                inc             rdi
                inc             rsi

                # check file buffer nul reached
                cmp             byte ptr [rdi], 0
                je              findStringToken_finished

                # check token buffer nul reache
                cmp             byte ptr [rsi], 0
                je              findStringToken_finished

                # check matches
                mov             rax, [rsi]
                cmp             byte ptr [rdi], al
                je              findStringToken_checkToken

                # not, reset token buffer and return
                mov             rsi, rbx
                jmp             findStringToken_loop

findStringToken_finished:
                ret