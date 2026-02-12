# Initialize link address for apps
if(NRE_TARGET STREQUAL "x86_64")
    set(APP_LINK_ADDR 0x300000000)
else()
    set(APP_LINK_ADDR 0x100000)
endif()
set(APP_INDEX 0)

include(${NRE_ROOT_DIR}/cmake/NRETargets.cmake)

add_subdirectory(cycleburner)
add_subdirectory(disktest)
add_subdirectory(sub)
add_subdirectory(sysinfo)
add_subdirectory(test)
add_subdirectory(unittests)
add_subdirectory(vmmng)
