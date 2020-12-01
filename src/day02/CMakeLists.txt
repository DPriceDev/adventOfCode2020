cmake_minimum_required(VERSION 3.17)

add_executable(day02 day02.s)
target_link_libraries(day02 apollo)

add_custom_command(
        TARGET day02 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/input.txt
        ${CMAKE_CURRENT_BINARY_DIR}/input.txt)