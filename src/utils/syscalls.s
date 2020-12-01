
.global syscall_exit
.global syscall_read
.global syscall_write
.global syscall_open
.global syscall_close

.data
    syscall_exit:   .quad      0x2000001
    syscall_read:   .quad      0x2000003
    syscall_write:  .quad      0x2000004
    syscall_open:   .quad      0x2000005
    syscall_close:  .quad      0x2000006