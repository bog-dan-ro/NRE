include_guard(GLOBAL)

function(nre_apply_arch_and_toolchain_flags target)
    if(NRE_TARGET STREQUAL "x86_64")
        target_compile_options(${target} PRIVATE -mcmodel=large)
        target_link_options(${target} PRIVATE -mcmodel=large -Wl,--no-relax)
    endif()

    if(NRE_CC STREQUAL "clang")
        target_compile_options(${target} PRIVATE -target ${CLANG_TARGET} -mstackrealign)
    endif()
endfunction()

function(nre_link_common_libraries target)
    target_link_libraries(${target} stdc++ supc++ g c m)
endfunction()

function(nre_add_crt0 target)
    target_sources(${target} PRIVATE ${LIB_DIR}/crt0.o)
endfunction()

function(nre_set_app_output_dir target)
    set_target_properties(${target} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${APP_DIR})
endfunction()

function(nre_get_git_revision out_var)
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
    set(${out_var} "${GIT_REVISION}" PARENT_SCOPE)
endfunction()

if(NOT DEFINED GUEST_FLAGS)
    set(GUEST_FLAGS -Wall -Wextra -ansi -m32 -g -O0 -fno-stack-protector)
endif()
if(NOT DEFINED GUEST_CXX_FLAGS)
    set(GUEST_CXX_FLAGS -Wall -Wextra -ansi -m32 -fno-exceptions -fno-rtti -g -O0 -fno-stack-protector)
endif()
if(NOT DEFINED GUEST_LINK_FLAGS)
    set(GUEST_LINK_FLAGS -m32 -fno-hosted -nostdlib -Wall -Wextra -ansi -Wl,--build-id=none)
endif()
