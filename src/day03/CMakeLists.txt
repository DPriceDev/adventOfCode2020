cmake_minimum_required(VERSION 3.17)

add_executable(day03_part1 day03_part1.s)
target_link_libraries(day03_part1 apollo)

add_custom_command(
        TARGET day03_part1 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/input.txt
        ${CMAKE_CURRENT_BINARY_DIR}/input.txt)

add_executable(day03_part2 day03_part2.s)
target_link_libraries(day03_part2 apollo)

add_custom_command(
        TARGET day03_part2 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/input.txt
        ${CMAKE_CURRENT_BINARY_DIR}/input.txt)