
.global exit

# --------------------------------------------- #
# exit
exit:
                mov             rax, [syscall_exit + RIP]
                xor             rdi, rdi
                syscall