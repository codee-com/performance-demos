cmake_minimum_required(VERSION 3.10)
project(MATMUL C)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp -O3")
set(SOURCES matrix.c clock.c main.c)
include_directories(./ include)

add_executable(matmul ${SOURCES})

add_custom_target(run
    COMMAND matmul 1500
    DEPENDS matmul
    WORKING_DIRECTORY ${CMAKE_PROJECT_DIR}
)
