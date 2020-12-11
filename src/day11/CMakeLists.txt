cmake_minimum_required(VERSION 3.17)

add_executable(day11_part1 day11_part1.s)
target_link_libraries(day11_part1 apollo)
target_include_directories(day11_part1 PUBLIC .)

add_custom_command(
        TARGET day11_part1 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/input.txt
        ${CMAKE_CURRENT_BINARY_DIR}/input.txt)

add_executable(day11_part2 day11_part2.s)
target_link_libraries(day11_part2 apollo)
target_include_directories(day11_part2 PUBLIC .)

add_custom_command(
        TARGET day11_part2 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/input.txt
        ${CMAKE_CURRENT_BINARY_DIR}/input.txt)