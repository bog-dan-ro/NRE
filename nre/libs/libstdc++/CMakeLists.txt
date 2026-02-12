add_library(stdc++ STATIC)

target_sources(stdc++ PRIVATE
    Assert.cc
    CPU.cc
    Desc.cc
    Errors.cc
    Exception.cc
    Hip.cc
    Logging.cc
    RCU.cc
    String.cc
    Test.cc
    init.cc
    new.cc
    profile.cc
    pthread.cc
    stdlib.cc
    string.c
    dlmalloc/dlmalloc.c
    dlmalloc/dlmalloc-support.cc
    util/PCI.cc
    util/Random.cc
    arch/ExecEnv.cc
    arch/Guard.cc
    arch/Startup.cc
    arch/SyscallABI.cc
    arch/GlobalEc.s
    stream/ConsoleStream.cc
    stream/OStream.cc
    stream/Serial.cc
    subsystem/Child.cc
    subsystem/ChildManager.cc
    subsystem/ChildMemory.cc
    subsystem/ServiceRegistry.cc
    utcb/UtcbFrame.cc
    utcb/UtcbStack.cc
    cap/CapRange.cc
    cap/CapSelSpace.cc
    ipc/Service.cc
    ipc/ServiceCPUHandler.cc
    ipc/ServiceSession.cc
    kobj/GlobalThread.cc
    kobj/ObjCap.cc
    kobj/Pd.cc
    kobj/Sc.cc
    kobj/Thread.cc
    kobj/VCpu.cc
    mem/DataSpace.cc
    mem/DataSpaceDesc.cc
)

if(NRE_TARGET STREQUAL "x86_32")
    target_sources(stdc++ PRIVATE
        arch/x86_32/LocalEc.s
    )
elseif(NRE_TARGET STREQUAL "x86_64")
    target_sources(stdc++ PRIVATE
        arch/x86_64/LocalEc.s
    )
endif()

target_include_directories(stdc++ PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/../../include)
target_include_directories(stdc++ PRIVATE /usr/include /usr/include/x86_64-linux-gnu)

set_target_properties(stdc++ PROPERTIES ARCHIVE_OUTPUT_DIRECTORY ${LIB_DIR})
