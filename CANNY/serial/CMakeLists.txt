cmake_minimum_required(VERSION 3.10)
project(CANNY C)

find_package(OpenMP REQUIRED)

# Intel icc
if("${CMAKE_C_COMPILER_ID}" STREQUAL "Intel")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS} -parallel -O3")
# GNU gcc
elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS} -O3")
elseif("${CMAKE_C_COMPILER_ID}" MATCHES "Clang")
# LLVM clang-cl
  if (${CMAKE_C_COMPILER_FRONTEND_VARIANT} STREQUAL "MSVC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS} /O2")
# LLVM clang    
    elseif (${CMAKE_C_COMPILER_FRONTEND_VARIANT} STREQUAL "GNU")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS} -O3")
  endif()
# cl.exe
elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "MSVC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS} /O2 /Qpar")
endif()

set(ZIP_FILE "${CMAKE_CURRENT_SOURCE_DIR}/../15360_8640.zip")

include_directories(include)

add_executable(canny canny.c)
target_link_libraries(canny m)

add_custom_target(testvecs
    COMMAND ${CMAKE_COMMAND} -E tar xf ${ZIP_FILE}
    DEPENDS ${ZIP_FILE}
)


add_custom_target(run
    COMMAND canny testvecs/input/15360_8640.pgm 0.5 0.7 0.9
    DEPENDS testvecs canny
)
