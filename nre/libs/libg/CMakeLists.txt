add_library(g STATIC)

# Create empty library placeholder
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/empty_g.c" "/* Empty library */")

target_sources(g PRIVATE
    "${CMAKE_CURRENT_BINARY_DIR}/empty_g.c"
)

set_target_properties(g PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${LIB_DIR})
