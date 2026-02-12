set(APP_LDSCRIPT "default")
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/ld.conf")
    set(APP_LDSCRIPT "root")
endif()

add_nre_app(unittests
    SOURCES
        unittests.cc
        tests/CatchEx.cc
        tests/CyclerTest.cc
        tests/DListTest.cc
        tests/DataSpaceTest.cc
        tests/DelegatePerf.cc
        tests/MaskListTest.cc
        tests/MemOps.cc
        tests/OStreamTest.cc
        tests/Pingpong.cc
        tests/PingpongXPd.cc
        tests/ProducerConsumer.cc
        tests/RegMngTest.cc
        tests/SListTest.cc
        tests/SListTreapTest.cc
        tests/Sessions.cc
        tests/SharedMemory.cc
        tests/SortedSListTest.cc
        tests/ThreadRefs.cc
        tests/ThreadsTest.cc
        tests/TreapTest.cc
        tests/UtcbTest.cc
    LDSCRIPT ${APP_LDSCRIPT}
)
