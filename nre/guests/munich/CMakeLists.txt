set(MUNICH_LDSCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/munich.ld")

add_nre_guest(guest_munich
    SOURCES
        asm.s
        boot_linux.s
        munich.c
        util.c
    LDSCRIPT ${MUNICH_LDSCRIPT}
)

target_compile_options(guest_munich PRIVATE
    -mregparm=3
    -ffreestanding
    $<$<COMPILE_LANGUAGE:C>:-std=gnu99>
)

target_link_options(guest_munich PRIVATE
    -ffreestanding
)
