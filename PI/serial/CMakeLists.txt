cmake_minimum_required(VERSION 3.10)
project(PI C)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp -O3")

add_executable(pi pi.c)
target_link_libraries(pi m)

add_custom_target(run
    COMMAND pi 1000000000
    DEPENDS pi
    WORKING_DIRECTORY ${CMAKE_PROJECT_DIR}
)
