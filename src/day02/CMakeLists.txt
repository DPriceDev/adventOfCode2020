cmake_minimum_required(VERSION 3.17)

add_executable(day02_part1 day02_part1.s)
target_link_libraries(day02_part1 apollo)

add_custom_command(
        TARGET day02_part1 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/input.txt
        ${CMAKE_CURRENT_BINARY_DIR}/input.txt)

add_executable(day02_part2 day02_part2.s)
target_link_libraries(day02_part2 apollo)

add_custom_command(
        TARGET day02_part2 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/input.txt
        ${CMAKE_CURRENT_BINARY_DIR}/input.txt)