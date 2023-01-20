cmake_minimum_required(VERSION 3.10)
project(ATMUX C)

find_package(OpenMP REQUIRED)

# Intel icc
if("${CMAKE_C_COMPILER_ID}" STREQUAL "Intel")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS} -parallel -std=c99 -O3")
# GNU gcc
elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS} -std=c99 -O3")
elseif("${CMAKE_C_COMPILER_ID}" MATCHES "Clang")
# LLVM clang-cl
  if (${CMAKE_C_COMPILER_FRONTEND_VARIANT} STREQUAL "MSVC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS} /O2")
# LLVM clang    
    elseif (${CMAKE_C_COMPILER_FRONTEND_VARIANT} STREQUAL "GNU")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS} -std=c99 -O3")
  endif()
# cl.exe
elseif("${CMAKE_C_COMPILER_ID}" STREQUAL "MSVC")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${OpenMP_C_FLAGS} /O2 /Qpar")
endif()

include_directories(lib)

add_executable(atmux 
    lib/Matrix2D.c
    lib/Vector.c
    lib/CRSMatrix.c
    atmux.c
)

add_custom_target(run
    COMMAND atmux 10000
    DEPENDS atmux
)
