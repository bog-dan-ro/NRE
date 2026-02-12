add_library(m STATIC)

# Create empty library placeholder
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/empty_m.c" "/* Empty library */")

target_sources(m PRIVATE
    "${CMAKE_CURRENT_BINARY_DIR}/empty_m.c"
)

set_target_properties(m PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${LIB_DIR})
