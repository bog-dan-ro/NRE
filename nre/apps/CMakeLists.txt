# Build each app subdirectory
set(APPS_DIR ${CMAKE_CURRENT_SOURCE_DIR})
file(GLOB APP_DIRS "${APPS_DIR}/*")

# Sort directories for deterministic ordering
list(SORT APP_DIRS)

# Initialize link address for apps
if(NRE_TARGET STREQUAL "x86_64")
    set(APP_LINK_ADDR 0x300000000)
else()
    set(APP_LINK_ADDR 0x100000)
endif()
set(APP_INDEX 0)

foreach(APP_PATH ${APP_DIRS})
    if(IS_DIRECTORY ${APP_PATH} AND NOT ${APP_PATH} MATCHES ".*\\..*")
        get_filename_component(APP_NAME ${APP_PATH} NAME)

        # Collect source files
        file(GLOB APP_SOURCES "${APP_PATH}/*.cc" "${APP_PATH}/*.c" "${APP_PATH}/*.s" "${APP_PATH}/*.S")

        # Skip if only SConscript file
        if(APP_SOURCES)
            # Determine linker script
            set(APP_LDSCRIPT "default")
            if(EXISTS "${APP_PATH}/ld.conf")
                set(APP_LDSCRIPT "root")
            endif()

            # Calculate link address for this app
            math(EXPR CURRENT_APP_LINK_ADDR "${APP_LINK_ADDR} + (${APP_INDEX} * 0x100000)")

            # Create executable
            add_executable(${APP_NAME} ${APP_SOURCES})

            # Architecture-specific flags
            if(NRE_TARGET STREQUAL "x86_64")
                target_compile_options(${APP_NAME} PRIVATE -mcmodel=large)
                target_link_options(${APP_NAME} PRIVATE -mcmodel=large -Wl,--no-relax)
            endif()

            # Clang specific flags
            if(NRE_CC STREQUAL "clang")
                target_compile_options(${APP_NAME} PRIVATE -target ${CLANG_TARGET} -mstackrealign)
            endif()

            # Link with libraries
            target_link_libraries(${APP_NAME} stdc++ supc++ g c m)

            # Set link address
            target_link_options(${APP_NAME} PRIVATE -Wl,--section-start=.text=${CURRENT_APP_LINK_ADDR})

            # Add linker script
            target_link_options(${APP_NAME} PRIVATE -Wl,-T,${CMAKE_CURRENT_SOURCE_DIR}/../toolchain/${APP_LDSCRIPT}.ld)

            # Add CRT0
            target_sources(${APP_NAME} PRIVATE ${LIB_DIR}/crt0.o)

            # Set output directory
            set_target_properties(${APP_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${APP_DIR})

            math(EXPR APP_INDEX "${APP_INDEX} + 1")
        endif()
    endif()
endforeach()
