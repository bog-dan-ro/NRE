add_library(c STATIC)

target_sources(c PRIVATE
    gcc14-compat.c
)

set_target_properties(c PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${LIB_DIR})
