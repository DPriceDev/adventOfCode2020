.include "methods.s"

.global _main

# --------------------------------------------- #
# Variables
.data
inputsFileName: .asciz          "input.txt"
fileDescriptor: .quad           4

firstNumber:    .quad           0
secondNumber:   .quad           0
multiple:       .quad           0
count:          .quad           200

failedMessage:  .asciz          "Failed to find 2020"
foundMessage:   .asciz          "Found 2020 from: "
andMessage:     .asciz          " and "
multipleMessage:.asciz          "The multiple is: "

.bss
memory:         .lcomm          buffer, 32

# --------------------------------------------- #
# Main
.text
_main:
                push           1977
                push           1802
                push           1856
                push           1309
                push           2003
                push           1854
                push           1898
                push           1862
                push           1857
                push           542
                push           1616
                push           1599
                push           1628
                push           1511
                push           1848
                push           1623
                push           1959
                push           1693
                push           1444
                push           1211
                push           1551
                push           1399
                push           1855
                push           1538
                push           1869
                push           1664
                push           1719
                push           1241
                push           1875
                push           1733
                push           1547
                push           1813
                push           1531
                push           1773
                push           624
                push           1336
                push           1897
                push           1179
                push           1258
                push           1205
                push           1727
                push           1364
                push           1957
                push           540
                push           1970
                push           1273
                push           1621
                push           1964
                push           1723
                push           1699
                push           1847
                push           1249
                push           1254
                push           1644
                push           1449
                push           1794
                push           1797
                push           1713
                push           1534
                push           1202
                push           1951
                push           1598
                push           1926
                push           1865
                push           1294
                push           1893
                push           1641
                push           1325
                push           1432
                push           1960
                push           413
                push           1517
                push           1724
                push           1715
                push           1458
                push           1775
                push           1317
                push           1694
                push           1484
                push           1840
                push           1999
                push           1811
                push           1578
                push           1658
                push           1906
                push           1481
                push           1313
                push           1997
                push           1339
                push           1592
                push           1971
                push           1453
                push           1706
                push           1884
                push           1956
                push           1384
                push           1579
                push           1689
                push           1726
                push           1217
                push           1796
                push           1536
                push           1213
                push           1867
                push           1304
                push           2010
                push           1503
                push           1665
                push           1361
                push           814
                push           2007
                push           1430
                push           1625
                push           1958
                push           860
                push           1799
                push           1942
                push           1876
                push           1772
                push           1198
                push           1221
                push           1814
                push           1826
                push           1667
                push           1334
                push           1504
                push           1420
                push           1164
                push           1414
                push           1934
                push           1823
                push           1507
                push           1195
                push           21
                push           1752
                push           1472
                push           1196
                push           1558
                push           1322
                push           1927
                push           1556
                push           1922
                push           277
                push           1828
                push           1883
                push           1280
                push           1947
                push           1231
                push           1915
                push           1235
                push           1961
                push           1494
                push           1324
                push           2009
                push           1367
                push           1545
                push           1736
                push           1575
                push           1214
                push           1704
                push           1833
                push           1663
                push           1474
                push           1894
                push           1754
                push           1564
                push           1321
                push           1119
                push           1975
                push           1987
                push           1873
                push           1834
                push           1686
                push           1574
                push           1505
                push           1656
                push           1688
                push           1896
                push           1982
                push           1554
                push           1990
                push           1902
                push           1859
                push           1293
                push           1739
                push           1282
                push           1889
                push           1981
                push           1283
                push           1687
                push           1220
                push           1443
                push           1409
                push           1252
                push           1506
                push           1742
                push           1319
                push           1882
                push           951
                push           1849

                mov             r9, [count + RIP]               # set number of inputs todo: read from file
                jmp             checkLoop

                # pop the stack when a number is finished being checked
popStack:
                pop             rax

                # decrease the counter
checkLoop:
                mov             rdx, r9                         # move the currently left input count to rdx
                dec             r9                              # decrease the r9 counter for overall inputs

                cmp             r9, 0                           # if no inputs left, finish
                je              failed

                mov             rdi, rsp                        # move the stack pointer into rdi

                # loop checking each addition
additionLoop:
                dec             rdx                             # decrement the loop count
                cmp             rdx, 0                          # check if zero, if so, jump to check loop
                je              popStack

                mov             rax, [rsp]                      # mov the value at the stack pointer to rax
                add             rdi, 8                          # decrement the rdi pointer to get the next value
                mov             rsi, [rdi]
                add             rax, rsi                        # add the values at both pointers

                cmp             rax, 2020                       # if they do not add to 2020, loop
                jne             additionLoop

                # found code
found:
                mov             [firstNumber + RIP], rsi        # save the winning numbers in the variables
                mov             rax, [rsp]
                mov             [secondNumber + RIP], rax

                mov             rax, [secondNumber + RIP]       # multiply found numbers
                mov             rdi, [firstNumber + RIP]
                mul             rdi
                mov             [multiple + RIP], rax

                # Print found!
                lea             rsi, [foundMessage + RIP]       # print found
                call            printString

                mov             rax, [secondNumber + RIP]       # print number
                call            printInteger

                lea             rsi, [andMessage + RIP]         # print and
                call            printString

                mov             rax, [firstNumber + RIP]        # print other number
                call            printLnInteger

                lea             rsi, [multipleMessage + RIP]    # print multiple message
                call            printString

                mov             rax, [multiple + RIP]           # print multiple
                call            printLnInteger

                jmp             finished

failed:
                # Print not found..
                lea             rsi, [failedMessage + RIP]
                call            printString

finished:
                # Exit
                call            exit