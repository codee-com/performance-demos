cmake_minimum_required(VERSION 3.10)
project(ATMUX C)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -fopenmp -O3")
set(SOURCES lib/Matrix2D.c lib/Vector.c lib/CRSMatrix.c atmux.c)
include_directories(lib)

add_executable(atmux ${SOURCES})

add_custom_target(run
    COMMAND atmux 10000
    DEPENDS atmux
    WORKING_DIRECTORY ${CMAKE_PROJECT_DIR}
)
