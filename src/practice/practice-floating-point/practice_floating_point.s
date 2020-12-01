.global _main

# ------------------------------------------------------------- #
# Variables
.data
valueA:         .float          123.4533
valueB:         .float          456.78
result:         .float          0.0



.bss

# ------------------------------------------------------------- #
# Main
.text
_main:
                lea             rax, [result + RIP]

                # Add floating point numbers
                fld             dword ptr [valueA + RIP]
                fadd            dword ptr [valueB + RIP]
                fstp            dword ptr [result + RIP]

                fld             dword ptr [result + RIP]
                fadd            dword ptr [valueB + RIP]
                fstp            dword ptr [result + RIP]

                # subtract floating point numbers
                fld             dword ptr [result + RIP]
                fsub            dword ptr [valueA + RIP]
                fstp            dword ptr [result + RIP]

                fld             dword ptr [result + RIP]
                fsub            dword ptr [valueB + RIP]
                fstp            dword ptr [result + RIP]

                # multiply floating point numbers

                # divide floating point numbers


                call            exit                            # Exit Program