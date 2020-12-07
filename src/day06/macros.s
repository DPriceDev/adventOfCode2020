# ------------------------------------------------------------- #
# Macros
# split string by token
.macro ssbt     outputBuffer tokenPointer
                lea             rdi, \outputBuffer              # line output buffer
                lea             rsi, \tokenPointer              # pointer to token string
                call            splitStringToken
                lea             rdi, \outputBuffer
.endm

# read file to buffer
.macro rftb     file buffer size
                mov             rax, [syscall_read + RIP]       # set sys call as read
                mov             rdi, \file
                lea             rsi, \buffer
                mov             rdx, \size
                syscall
.endm

# read file to buffer
.macro oftb     name buffer size
                lea             rdi, \name                      # move address of filename string to rdi
                call            openfile
                mov             rdi, rax                        # save returned file descriptor

                rftb            rdi, \buffer, \size

                call            closefile
                pop             rax
.endm

# ------------------------------------------------------------- #