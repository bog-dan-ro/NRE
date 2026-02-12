# Guests are 32-bit user-space binaries
set(GUEST_FLAGS -Wall -Wextra -ansi -m32 -g -O0 -fno-stack-protector)
set(GUEST_CXX_FLAGS -Wall -Wextra -ansi -m32 -fno-exceptions -fno-rtti -g -O0 -fno-stack-protector)
set(GUEST_LINK_FLAGS -m32 -fno-hosted -nostdlib -Wall -Wextra -ansi -Wl,--build-id=none)

# Build each guest subdirectory
set(GUESTS_DIR ${CMAKE_CURRENT_SOURCE_DIR})
file(GLOB GUEST_DIRS "${GUESTS_DIR}/*")

foreach(GUEST_PATH ${GUEST_DIRS})
    if(IS_DIRECTORY ${GUEST_PATH} AND NOT ${GUEST_PATH} MATCHES ".*\\..*")
        get_filename_component(GUEST_NAME ${GUEST_PATH} NAME)

        # Collect source files
        file(GLOB GUEST_SOURCES "${GUEST_PATH}/src/*.cc" "${GUEST_PATH}/src/*.s" "${GUEST_PATH}/src/*.S" "${GUEST_PATH}/src/*.c")

        # Skip if no sources
        if(GUEST_SOURCES)
            # Create guest binary name
            set(GUEST_BIN_NAME "guest_${GUEST_NAME}")

            # Create executable
            add_executable(${GUEST_BIN_NAME} ${GUEST_SOURCES})

            # Set compiler flags for guests
            target_compile_options(${GUEST_BIN_NAME} PRIVATE ${GUEST_FLAGS})
            target_compile_options(${GUEST_BIN_NAME} PRIVATE $<$<COMPILE_LANGUAGE:CXX>:${GUEST_CXX_FLAGS}>)

            # Set linker flags
            target_link_options(${GUEST_BIN_NAME} PRIVATE ${GUEST_LINK_FLAGS})

            # Check if there's a custom linker script
            if(EXISTS "${GUEST_PATH}/src/ld.conf")
                target_link_options(${GUEST_BIN_NAME} PRIVATE -Wl,-T,${GUEST_PATH}/src/ld.conf)
            endif()

            # Add include directory if exists
            if(EXISTS "${GUEST_PATH}/include")
                target_include_directories(${GUEST_BIN_NAME} PRIVATE ${GUEST_PATH}/include)
            endif()

            # Set output directory
            set_target_properties(${GUEST_BIN_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${APP_DIR})
        endif()
    endif()
endforeach()
