cmake_minimum_required(VERSION 3.10)
project(common C)

set (BINDIR	${CMAKE_CURRENT_SOURCE_DIR}/../bin)
set (BENCHMARK_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../${BENCHMARKU})
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -Wall -O3 -fopenmp -mcmodel=medium")
set(COMMON ${CMAKE_CURRENT_SOURCE_DIR})


# Class "U" is used internally by the setparams program to mean
# "unknown". This means that if you don't specify CLASS=
# on the command line, you'll get an error. It would be nice
# to be able to avoid this, but we'd have to get information
# from the setparams back to the make program, which isn't easy. 
set(BENCHMARK_CLASS "U")

# set (PROGRAM  $(BINDIR)/$(BENCHMARK).$(BENCHMARK_CLASS).x)

add_library(print_results OBJECT print_results.c)
add_library(c_print_results OBJECT c_print_results.c)
add_library(randdp OBJECT randdp.c)
add_library(c_timers OBJECT c_timers.c)
add_library(wtime OBJECT wtime.c)
