
.global openfile
.global closefile
.global writefile

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
# Get the size of a file
# mov           rdi, "file descriptor"
# lea           rsi, "pointer to buffer"
# mov           rdx, "length of buffer to write"
writefile:
                mov             rax, [syscall_write + RIP]
                syscall
                ret