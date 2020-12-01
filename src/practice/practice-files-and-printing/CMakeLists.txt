cmake_minimum_required(VERSION 3.17)

add_executable(practiceFilesAndPrinting practice_files_and_printing.s)
target_link_libraries(practiceFilesAndPrinting apollo)

add_custom_command(
        TARGET practiceFilesAndPrinting POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/input.txt
        ${CMAKE_CURRENT_BINARY_DIR}/input.txt)