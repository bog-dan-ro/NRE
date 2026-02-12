add_subdirectory(libc)
add_subdirectory(libg)
add_subdirectory(libm)
add_subdirectory(libstdc++)

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
