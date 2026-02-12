set(APP_LDSCRIPT "default")
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/ld.conf")
    set(APP_LDSCRIPT "root")
endif()

add_nre_app(sysinfo
    SOURCES
        PdInfoPage.cc
        ScInfoPage.cc
        sysinfo.cc
    LDSCRIPT ${APP_LDSCRIPT}
)
