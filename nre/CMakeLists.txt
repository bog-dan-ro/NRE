cmake_minimum_required(VERSION 3.31)

# Get target and build type from environment variables
set(NRE_TARGET "$ENV{NRE_TARGET}")
set(NRE_BUILD "$ENV{NRE_BUILD}")
set(NRE_CC "$ENV{NRE_CC}")

# Default values
if(NOT NRE_TARGET)
    set(NRE_TARGET "x86_64")
endif()
if(NOT NRE_BUILD)
    set(NRE_BUILD "release")
endif()
if(NOT NRE_CC)
    set(NRE_CC "gcc")
endif()

# Validate target
if(NOT NRE_TARGET MATCHES "^(x86_32|x86_64)$")
    message(FATAL_ERROR "NRE_TARGET must be x86_32 or x86_64, got ${NRE_TARGET}")
endif()

# Set up cross-compiler for x86_32
if(NRE_TARGET STREQUAL "x86_32")
    set(CROSS_PREFIX "i686-pc-nulnova-")
    set(CMAKE_SYSTEM_NAME SysV)
    set(CMAKE_SYSTEM_PROCESSOR i686)
else()
    set(CROSS_PREFIX "")
    set(CMAKE_SYSTEM_NAME SysV)
    set(CMAKE_SYSTEM_PROCESSOR x86-64)
endif()

# Set up compilers
if(NRE_CC STREQUAL "clang")
    find_program(CMAKE_CXX_COMPILER clang++ REQUIRED)
    find_program(CMAKE_C_COMPILER clang REQUIRED)
    if(NRE_TARGET STREQUAL "x86_64")
        set(CLANG_TARGET "x86_64-pc-linux-gnu")
    else()
        set(CLANG_TARGET "i686-pc-linux-gnu")
    endif()
else()
    if(CROSS_PREFIX)
        find_program(CMAKE_CXX_COMPILER ${CROSS_PREFIX}g++ REQUIRED)
        find_program(CMAKE_C_COMPILER ${CROSS_PREFIX}gcc REQUIRED)
        find_program(CMAKE_LINKER ${CROSS_PREFIX}ld REQUIRED)
        find_program(CMAKE_ASM_COMPILER ${CROSS_PREFIX}as REQUIRED)
        set(CMAKE_CXX_COMPILER_ID "GNU")
        set(CMAKE_C_COMPILER_ID "GNU")
    else()
        find_program(CMAKE_CXX_COMPILER g++-14 REQUIRED)
        find_program(CMAKE_C_COMPILER gcc-14 REQUIRED)
    endif()
endif()

set(CMAKE_ASM_COMPILER ${CMAKE_C_COMPILER})
set(CMAKE_ASM_COMPILE_OBJECT "<CMAKE_C_COMPILER> <DEFINES> <INCLUDES> <FLAGS> -o <OBJECT> -c <SOURCE>")

project(NRE LANGUAGES C CXX ASM)

# Set build type
if(NRE_BUILD STREQUAL "debug")
    set(CMAKE_BUILD_TYPE Debug)
else()
    set(CMAKE_BUILD_TYPE Release)
endif()

# Build directory setup
set(BUILD_DIR "${CMAKE_BINARY_DIR}")
set(BIN_DIR "${BUILD_DIR}/bin")
set(LIB_DIR "${BUILD_DIR}/lib")
set(APP_DIR "${BIN_DIR}/apps")

file(MAKE_DIRECTORY "${BIN_DIR}")
file(MAKE_DIRECTORY "${LIB_DIR}")
file(MAKE_DIRECTORY "${APP_DIR}")

# C/C++ standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Common compile flags
set(COMMON_FLAGS "-Wall -Wextra -msse2")
set(CMAKE_C_FLAGS "${COMMON_FLAGS} ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS "${COMMON_FLAGS} -std=c++17 ${CMAKE_CXX_FLAGS}")

# Add NRE-specific defines
add_compile_definitions(
    __nova__
    __NOVA__
    nova
    __GXX_MERGED_TYPEINFO_NAMES=0
    __GXX_TYPEINFO_EQUALITY_INLINE=0
)

# Optimization flags
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_compile_options(-O0 -ggdb)
else()
    add_compile_options(-O3 -DNDEBUG -fno-omit-frame-pointer)
    # LTO is disabled for bare-metal builds due to linker issues
    # set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
endif()

# Linker flags for bare metal
set(CMAKE_EXE_LINKER_FLAGS "-nostartfiles -Wl,--no-undefined -static -Wl,-static -static-libgcc -Wl,-z,max-page-size=0x1000 ${CMAKE_EXE_LINKER_FLAGS}")

# Include directories
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/include)

# Helper function to create NRE programs
set(LINK_ADDR_X86_64 0x300000000)
set(LINK_ADDR_X86_32 0x100000)
set(CURRENT_LINK_ADDR ${LINK_ADDR_${NRE_TARGET}})

function(add_nre_program target)
    set(oneValueArgs LDSCRIPT FIXED_ADDR)
    set(multiValueArgs SOURCES INCLUDE_DIRS LIBRARIES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    add_executable(${target} ${ARG_SOURCES})

    # Add include directories
    if(ARG_INCLUDE_DIRS)
        target_include_directories(${target} PRIVATE ${ARG_INCLUDE_DIRS})
    endif()

    # Add libraries
    if(ARG_LIBRARIES)
        target_link_libraries(${target} ${ARG_LIBRARIES})
    endif()

    # Set linker script
    set(LDSCRIPT "default")
    if(ARG_LDSCRIPT)
        set(LDSCRIPT ${ARG_LDSCRIPT})
    endif()

    # Add CRT0
    target_sources(${target} PRIVATE ${LIB_DIR}/crt0.o)

    # Link with standard libraries
    target_link_libraries(${target} stdc++ supc++ g c m)

    # Set link address if not fixed
    if(NOT ARG_FIXED_ADDR)
        target_link_options(${target} PRIVATE -Wl,--section-start=.text=${CURRENT_LINK_ADDR})
        math(EXPR CURRENT_LINK_ADDR "${CURRENT_LINK_ADDR} + 0x100000")
        set(CURRENT_LINK_ADDR ${CURRENT_LINK_ADDR} PARENT_SCOPE)
    endif()

    # Add linker script
    target_link_options(${target} PRIVATE -Wl,-T,${CMAKE_CURRENT_SOURCE_DIR}/../../toolchain/${LDSCRIPT}.ld)

    # Set output directory
    set_target_properties(${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${APP_DIR})
endfunction()

# Add subdirectories
add_subdirectory(libs)
add_subdirectory(services)
add_subdirectory(apps)
add_subdirectory(guests)
add_subdirectory(tools)
add_subdirectory(dist)

# Export build variables for scripts
set(NRE_BUILD_DIR "${BUILD_DIR}")
set(NRE_TARGET_ARCH "${NRE_TARGET}")
set(NRE_BUILD_TYPE "${NRE_BUILD}")
