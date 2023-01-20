cmake_minimum_required(VERSION 3.10)
project(COULOMB C)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fopenmp -O3")
set(SOURCES Vector.c Matrix2D.c coulomb.c)
include_directories(./ include)

add_executable(coulomb ${SOURCES})
target_link_libraries(coulomb m)

add_custom_target(run
    COMMAND coulomb 400
    DEPENDS coulomb
    WORKING_DIRECTORY ${CMAKE_PROJECT_DIR}
)
