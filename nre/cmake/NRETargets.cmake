include_guard(GLOBAL)
include(${NRE_ROOT_DIR}/cmake/NRECommon.cmake)

function(add_nre_app target)
    set(oneValueArgs LDSCRIPT)
    set(multiValueArgs SOURCES)
    cmake_parse_arguments(APP "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    add_executable(${target} ${APP_SOURCES})

    nre_apply_arch_and_toolchain_flags(${target})
    nre_link_common_libraries(${target})

    math(EXPR CURRENT_APP_LINK_ADDR "${APP_LINK_ADDR} + (${APP_INDEX} * 0x100000)")
    target_link_options(${target} PRIVATE -Wl,--section-start=.text=${CURRENT_APP_LINK_ADDR})

    if(APP_LDSCRIPT)
        set(APP_LDSCRIPT_NAME ${APP_LDSCRIPT})
    else()
        set(APP_LDSCRIPT_NAME "default")
    endif()
    target_link_options(${target} PRIVATE -Wl,-T,${NRE_ROOT_DIR}/toolchain/${APP_LDSCRIPT_NAME}.ld)

    nre_add_crt0(${target})
    nre_set_app_output_dir(${target})

    math(EXPR APP_INDEX "${APP_INDEX} + 1")
    set(APP_INDEX "${APP_INDEX}" PARENT_SCOPE)
endfunction()

function(add_nre_service target)
    set(multiValueArgs SOURCES)
    cmake_parse_arguments(SERVICE "" "" "${multiValueArgs}" ${ARGN})

    add_executable(${target} ${SERVICE_SOURCES})

    nre_apply_arch_and_toolchain_flags(${target})
    nre_link_common_libraries(${target})

    if("${target}" STREQUAL "root" AND DEFINED GIT_REVISION)
        target_compile_definitions(${target} PRIVATE NRE_REV="${GIT_REVISION}")
    endif()

    math(EXPR CURRENT_SERVICE_LINK_ADDR "${SERVICE_LINK_ADDR} + (${SERVICE_INDEX} * 0x100000)")
    target_link_options(${target} PRIVATE -Wl,--section-start=.text=${CURRENT_SERVICE_LINK_ADDR})

    target_link_options(${target} PRIVATE -Wl,-T,${NRE_ROOT_DIR}/toolchain/default.ld)

    nre_add_crt0(${target})
    nre_set_app_output_dir(${target})

    math(EXPR SERVICE_INDEX "${SERVICE_INDEX} + 1")
    set(SERVICE_INDEX "${SERVICE_INDEX}" PARENT_SCOPE)
endfunction()

function(add_nre_guest target)
    set(oneValueArgs LDSCRIPT)
    set(multiValueArgs SOURCES INCLUDE_DIRS)
    cmake_parse_arguments(GUEST "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    add_executable(${target} ${GUEST_SOURCES})

    target_compile_options(${target} PRIVATE ${GUEST_FLAGS})
    target_compile_options(${target} PRIVATE $<$<COMPILE_LANGUAGE:CXX>:${GUEST_CXX_FLAGS}>)

    target_link_options(${target} PRIVATE ${GUEST_LINK_FLAGS})

    if(GUEST_LDSCRIPT)
        target_link_options(${target} PRIVATE -Wl,-T,${GUEST_LDSCRIPT})
    endif()

    if(GUEST_INCLUDE_DIRS)
        target_include_directories(${target} PRIVATE ${GUEST_INCLUDE_DIRS})
    endif()

    set_target_properties(${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${APP_DIR})
endfunction()

function(add_nre_program target)
    set(oneValueArgs LDSCRIPT FIXED_ADDR)
    set(multiValueArgs SOURCES INCLUDE_DIRS LIBRARIES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    add_executable(${target} ${ARG_SOURCES})

    if(ARG_INCLUDE_DIRS)
        target_include_directories(${target} PRIVATE ${ARG_INCLUDE_DIRS})
    endif()

    if(ARG_LIBRARIES)
        target_link_libraries(${target} ${ARG_LIBRARIES})
    endif()

    set(LDSCRIPT "default")
    if(ARG_LDSCRIPT)
        set(LDSCRIPT ${ARG_LDSCRIPT})
    endif()

    target_sources(${target} PRIVATE ${LIB_DIR}/crt0.o)

    target_link_libraries(${target} stdc++ supc++ g c m)

    if(NOT ARG_FIXED_ADDR)
        target_link_options(${target} PRIVATE -Wl,--section-start=.text=${CURRENT_LINK_ADDR})
        math(EXPR CURRENT_LINK_ADDR "${CURRENT_LINK_ADDR} + 0x100000")
        set(CURRENT_LINK_ADDR ${CURRENT_LINK_ADDR} PARENT_SCOPE)
    endif()

    target_link_options(${target} PRIVATE -Wl,-T,${CMAKE_CURRENT_SOURCE_DIR}/../../toolchain/${LDSCRIPT}.ld)

    set_target_properties(${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${APP_DIR})
endfunction()
