cmake_minimum_required(VERSION 3.17)

add_executable(practice01 practice01.s ../../utils/methods.s)

add_custom_command(
        TARGET practice01 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/input.txt
        ${CMAKE_CURRENT_BINARY_DIR}/input.txt)