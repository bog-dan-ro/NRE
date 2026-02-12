set(GUEST_SOURCES
    src/gdt.cc
    src/idt.cc
    src/keyb.cc
    src/main.cc
    src/paging.cc
    src/pic.cc
    src/pit.cc
    src/printer.cc
    src/start.s
    src/util.cc
    src/video.cc
)

set(GUEST_LDSCRIPT "")
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/ld.conf")
    set(GUEST_LDSCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/src/ld.conf")
endif()

set(GUEST_INCLUDE_DIRS "")
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include")
    set(GUEST_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/include")
endif()

add_nre_guest(guest_mini
    SOURCES ${GUEST_SOURCES}
    INCLUDE_DIRS ${GUEST_INCLUDE_DIRS}
    LDSCRIPT ${GUEST_LDSCRIPT}
)
