add_library(c STATIC)
file(GLOB LIBC_SRCS libc/*.c)
if(LIBC_SRCS)
    target_sources(c PRIVATE ${LIBC_SRCS})
else()
    target_sources(c PRIVATE libc/gcc14-compat.c)
endif()

add_library(g STATIC)
file(GLOB LIBG_SRCS libg/*.c)
if(NOT LIBG_SRCS)
    # Create empty library placeholder
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/empty_g.c" "/* Empty library */")
    target_sources(g PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/empty_g.c")
else()
    target_sources(g PRIVATE ${LIBG_SRCS})
endif()

add_library(m STATIC)
file(GLOB LIBM_SRCS libm/*.c)
if(NOT LIBM_SRCS)
    # Create empty library placeholder
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/empty_m.c" "/* Empty library */")
    target_sources(m PRIVATE "${CMAKE_CURRENT_BINARY_DIR}/empty_m.c")
else()
    target_sources(m PRIVATE ${LIBM_SRCS})
endif()

# Build libstdc++
add_library(stdc++ STATIC)
file(GLOB LIBSTDCXX_CC libstdc++/*.cc libstdc++/*/*.cc libstdc++/arch/${NRE_TARGET}/*.cc)
file(GLOB LIBSTDCXX_C libstdc++/*.c libstdc++/*/*.c libstdc++/arch/${NRE_TARGET}/*.c)
file(GLOB LIBSTDCXX_S libstdc++/arch/*.s libstdc++/arch/${NRE_TARGET}/*.s)
target_sources(stdc++ PRIVATE ${LIBSTDCXX_CC} ${LIBSTDCXX_C} ${LIBSTDCXX_S})
target_include_directories(stdc++ PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../include)
target_include_directories(stdc++ PRIVATE /usr/include /usr/include/x86_64-linux-gnu)

# Build crt0.o from architecture-specific assembly
set(CRT0_SRC "${CMAKE_CURRENT_SOURCE_DIR}/libstdc++/arch/${NRE_TARGET}/crt0.S")
set(CRT0_OBJ "${LIB_DIR}/crt0.o")

add_custom_command(
    OUTPUT ${CRT0_OBJ}
    COMMAND ${CMAKE_C_COMPILER} -I${CMAKE_CURRENT_SOURCE_DIR}/../include -c ${CRT0_SRC} -o ${CRT0_OBJ}
    DEPENDS ${CRT0_SRC}
    COMMENT "Compiling crt0.o"
)

# Create a dummy target to ensure crt0.o is built
add_custom_target(crt0_build ALL DEPENDS ${CRT0_OBJ})
set_target_properties(c g m stdc++ PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${LIB_DIR})
