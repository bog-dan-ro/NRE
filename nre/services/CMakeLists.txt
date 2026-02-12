# Build services
set(SERVICES_DIR ${CMAKE_CURRENT_SOURCE_DIR})
file(GLOB SERVICE_DIRS "${SERVICES_DIR}/*")

# Sort directories for deterministic ordering
list(SORT SERVICE_DIRS)

# Initialize link address for services
if(NRE_TARGET STREQUAL "x86_64")
    set(SERVICE_LINK_ADDR 0x400000000)
else()
    set(SERVICE_LINK_ADDR 0x200000)
endif()
set(SERVICE_INDEX 0)

# Get git revision for NRE_REV
execute_process(
    COMMAND git describe --dirty --always
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/..
    OUTPUT_VARIABLE GIT_REVISION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)
if(NOT GIT_REVISION)
    set(GIT_REVISION "unknown")
endif()

foreach(SERVICE_PATH ${SERVICE_DIRS})
    if(IS_DIRECTORY ${SERVICE_PATH} AND NOT ${SERVICE_PATH} MATCHES ".*\\..*")
        get_filename_component(SERVICE_NAME ${SERVICE_PATH} NAME)

        # Collect source files (including all subdirectories)
        file(GLOB_RECURSE SERVICE_SOURCES "${SERVICE_PATH}/*.cc" "${SERVICE_PATH}/*.c")

        # Skip if only SConscript file
        if(SERVICE_SOURCES)
            # Calculate link address for this service
            math(EXPR CURRENT_SERVICE_LINK_ADDR "${SERVICE_LINK_ADDR} + (${SERVICE_INDEX} * 0x100000)")

            # Create executable
            add_executable(${SERVICE_NAME} ${SERVICE_SOURCES})

            # Architecture-specific flags
            if(NRE_TARGET STREQUAL "x86_64")
                target_compile_options(${SERVICE_NAME} PRIVATE -mcmodel=large)
                target_link_options(${SERVICE_NAME} PRIVATE -mcmodel=large -Wl,--no-relax)
            endif()

            # Clang specific flags
            if(NRE_CC STREQUAL "clang")
                target_compile_options(${SERVICE_NAME} PRIVATE -target ${CLANG_TARGET} -mstackrealign)
            endif()

            # Link with libraries
            target_link_libraries(${SERVICE_NAME} stdc++ supc++ g c m)

            # Special handling for root service
            if(SERVICE_NAME STREQUAL "root")
                target_compile_definitions(${SERVICE_NAME} PRIVATE NRE_REV="${GIT_REVISION}")
            endif()

            # Set link address
            target_link_options(${SERVICE_NAME} PRIVATE -Wl,--section-start=.text=${CURRENT_SERVICE_LINK_ADDR})

            # Add linker script
            target_link_options(${SERVICE_NAME} PRIVATE -Wl,-T,${CMAKE_CURRENT_SOURCE_DIR}/../toolchain/default.ld)

            # Add CRT0
            target_sources(${SERVICE_NAME} PRIVATE ${LIB_DIR}/crt0.o)

            # Set output directory
            set_target_properties(${SERVICE_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${APP_DIR})

            math(EXPR SERVICE_INDEX "${SERVICE_INDEX} + 1")
        endif()
    endif()
endforeach()
