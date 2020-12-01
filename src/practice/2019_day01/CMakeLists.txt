cmake_minimum_required(VERSION 3.17)

add_executable(2019_day01 answer.s ../../utils/print.s)

add_custom_command(
        TARGET 2019_day01 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/input.txt
        ${CMAKE_CURRENT_BINARY_DIR}/input.txt)