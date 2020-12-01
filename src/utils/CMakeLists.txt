cmake_minimum_required(VERSION 3.17)

add_library(apollo INTERFACE)
target_link_libraries(apollo INTERFACE string common file print syscall)

add_library(syscall syscalls.s)

add_library(string string.s)
target_link_libraries(string syscall)

add_library(common common.s)
target_link_libraries(common syscall)

add_library(file file.s)
target_link_libraries(file syscall)

add_library(print print.s)
target_link_libraries(print syscall)