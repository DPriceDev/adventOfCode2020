
.global _main

.include "macros.s"

# ------------------------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4
fileSize:       .quad           56000
splitToken:     .asciz          "\n"
nodeToken:      .asciz          " contain "
bagToken:       .asciz          ", "

.bss
fileBuffer:     .lcomm          fbuffer, 56000
lineBuffer:     .lcomm          lbuffer, 128
nodeBuffer:     .lcomm          nbuffer, 128
objectBuffer:   .lcomm          obuffer, 320000

# ------------------------------------------------------------- #
# Main
.text
_main:
                oftb            [inputsFileName + RIP], [fileBuffer + RIP], [fileSize + RIP]
# ------------------------------------------------------------- #
                lea             rdx, [fileBuffer + RIP]
                xor             r11, r11
splitLoop:
                cmp             byte ptr [rdx], 0               // check for null, finished when no more lines
                je              finished

                ssbt            [lineBuffer + RIP], [splitToken + RIP]

                push            rdx
                call            addNode
                pop             rdx

                inc             r11
                jmp             splitLoop
finished:
                lea             rdi, [objectBuffer + RIP]
                mov             rax, r11
                call            printInteger                    // print result
                call            exit

                // generate nodes
# ------------------------------------------------------------- #
addNode:
                lea             rdx, [lineBuffer + RIP]
                ssbt            [nodeBuffer + RIP], [nodeToken + RIP]

                // find address of existing object or new available address
                call            findBagObject

                // set value of address
                lea             rsi, [nodeBuffer + RIP]
                call            moveString

                xor             rax, rax
                xor             rbx, rbx
addNode_loop:
                cmp             byte ptr [rdx], 0
                je              addNode_finished

                cmp             byte ptr [rdx], '.'
                je              addNode_finished

                push            rax
                ssbt            [nodeBuffer + RIP], [bagToken + RIP]
                pop             rax

                // extract value and start of key name
                mov             bl, byte ptr [nodeBuffer + RIP]
                sub             bl, 48

                cmp             bl, 9
                jg              addNode_finished

                // find bag object
                lea             rcx, [nodeBuffer + RIP + 2]
                push            rdi
                call            findBagObject
                mov             rsi, rdi
                call            addBagToNodeContainsList        // add pointer to other bag and the number of bags to the contains list
                pop             rdi

                // check if the bag object was created? return from bag object a flag?

                call            addContainedValueToBag

                inc             rax
                jmp             addNode_loop
addNode_finished:
                ret

# ------------------------------------------------------------- #
findBagObject:
                // return rdi
                lea             rdi, [objectBuffer + RIP]
findBagObject_loop:


                // search object buffer for bag name
                // return if found

                add             rdi, 472


                // if not found, return next available address

findBagObject_finish:
                ret

# ------------------------------------------------------------- #
moveString:
                push            rsi
                push            rdi
                push            rax
moveString_loop:
                mov             rax, [rsi]
                mov             byte ptr [rdi], al
                inc             rsi
                inc             rdi
                cmp             byte ptr [rsi], 0
                jne             moveString_loop
moveString_finished:
                pop             rax
                pop             rdi
                pop             rsi
                ret

# ------------------------------------------------------------- #
compareString:
                push            rsi
                push            rdi
                push            rax
compareString_loop:
                mov             rax, [rsi]
                mov             byte ptr [rdi], al
                inc             rsi
                inc             rdi
                cmp             byte ptr [rsi], 0
                jne             moveString_loop
compareString_finished:
                pop             rax
                pop             rdi
                pop             rsi
                ret


# ------------------------------------------------------------- #
addBagToNodeContainsList:
                push            rdi
                push            rax

                add             rdi, 24
                shl             rax, 4
                add             rdi, rax

                // write register
                mov             [rdi], rsi
                // offset by a pointers length and write the value
                add             rdi, 8
                mov             byte ptr [rdi], bl

                pop             rax
                pop             rdi
                ret