cmake_minimum_required(VERSION 3.10)
project(CANNY C)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp -O3")
include_directories(./ include)

add_executable(canny canny.c)
target_link_libraries(canny m)

add_custom_target(testvecs
    COMMAND unzip -u ../15360_8640.zip
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

add_custom_target(run
    COMMAND canny ../testvecs/input/15360_8640.pgm 0.5 0.7 0.9
    DEPENDS testvecs canny
    WORKING_DIRECTORY ${CMAKE_PROJECT_DIR}
)
