cmake_minimum_required(VERSION 3.10)
project(HACCmk C)


set(CMAKE_C_FLAGS_MAIN "-O0 -fopenmp")

set_source_files_properties(main.c PROPERTIES COMPILE_FLAGS "-g -O0 -fopenmp -Wall")
set_source_files_properties(Step10_orig.c PROPERTIES COMPILE_FLAGS "-g -O3 -mavx2 -Wall")
set_source_files_properties(mysecond.c PROPERTIES COMPILE_FLAGS "-O0")

add_library(main_obj OBJECT main.c)
add_library(Step10_orig_obj OBJECT Step10_orig.c)
add_library(mysecond_obj OBJECT mysecond.c)

add_custom_target(build ALL
    COMMAND ${CMAKE_C_COMPILER} -O0 -fopenmp -o main $<TARGET_OBJECTS:main_obj> $<TARGET_OBJECTS:Step10_orig_obj> $<TARGET_OBJECTS:mysecond_obj> -L$ENV{HOME}/lib -lm
    DEPENDS main_obj Step10_orig_obj mysecond_obj
    WORKING_DIRECTORY ${CMAKE_PROJECT_DIR}
)

add_custom_target(run
    COMMAND ${CMAKE_CURRENT_BINARY_DIR}/main
    DEPENDS build
)
