cmake_minimum_required(VERSION 3.17)

add_executable(day01 day01.s)
target_link_libraries(day01 apollo)

add_custom_command(
        TARGET day01 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/input.txt
        ${CMAKE_CURRENT_BINARY_DIR}/input.txt)

add_executable(day01_part2 day01_part2.s)
target_link_libraries(day01_part2 apollo)

add_custom_command(
        TARGET day01_part2 POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/input.txt
        ${CMAKE_CURRENT_BINARY_DIR}/input.txt)