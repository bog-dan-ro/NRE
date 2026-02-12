# Initialize link address for services
if(NRE_TARGET STREQUAL "x86_64")
    set(SERVICE_LINK_ADDR 0x400000000)
else()
    set(SERVICE_LINK_ADDR 0x200000)
endif()
set(SERVICE_INDEX 0)

include(${NRE_ROOT_DIR}/cmake/NRETargets.cmake)

nre_get_git_revision(GIT_REVISION)

add_subdirectory(acpi)
add_subdirectory(keyboard)
add_subdirectory(network)
add_subdirectory(pcicfg)
add_subdirectory(reboot)
add_subdirectory(root)
add_subdirectory(storage)
add_subdirectory(timer)
