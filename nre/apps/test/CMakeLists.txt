set(APP_LDSCRIPT "default")
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/ld.conf")
    set(APP_LDSCRIPT "root")
endif()

add_nre_app(test
    SOURCES
        test.cc
    LDSCRIPT ${APP_LDSCRIPT}
)
