cmake_minimum_required(VERSION 3.17)

project(2020 LANGUAGES ASM)

set(CMAKE_ASM_FLAGS -masm=intel)

add_subdirectory(src)