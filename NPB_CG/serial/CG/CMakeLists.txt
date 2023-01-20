cmake_minimum_required(VERSION 3.10)
project(CG C)

set(TARGET ${BENCHMARK}.${BENCHMARK_CLASS}.x)
set(COMMON ${CMAKE_CURRENT_SOURCE_DIR}/../common)
set(config ${CMAKE_CURRENT_SOURCE_DIR}/../config)
set(config_bin ${CMAKE_CURRENT_BINARY_DIR}/../config)
set(sys ${CMAKE_CURRENT_SOURCE_DIR}/../sys)
set(sys_bin ${CMAKE_CURRENT_BINARY_DIR}/../sys)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O3 -fopenmp -mcmodel=medium")
set_source_files_properties(${BENCHMARK}.c PROPERTIES COMPILE_FLAGS "-I${COMMON} -g -Wall -O3 -fopenmp -mcmodel=medium")


configure_file(${config}/make.def ${config_bin}/make.def COPYONLY)

# Generate npbparams.h based
add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/npbparams.h
    COMMAND ${sys_bin}/setparams ${BENCHMARK} ${BENCHMARK_CLASS}
    DEPENDS setparams ${config}/make.def
)

add_library(${BENCHMARK} OBJECT ${BENCHMARK}.c npbparams.h globals.h)
target_include_directories(${BENCHMARK} PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_include_directories(${BENCHMARK} PRIVATE ${sys})

add_executable(${TARGET}
    ${BENCHMARK}.c
    ${COMMON}/print_results.c
    ${COMMON}/${RAND}.c
    ${COMMON}/c_timers.c
    ${COMMON}/${WTIME}
)

target_include_directories(${TARGET} PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
add_dependencies(${TARGET} ${BENCHMARK})
target_link_libraries(${TARGET} PRIVATE m)
