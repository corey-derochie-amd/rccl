# Source files
set(LIBSRCFILES
    bootstrap.cc
    channel.cc
    #ce_coll.cc
    collectives.cc
    debug.cc
    enqueue.cc
    group.cc
    init.cc
    init_nvtx.cc
    proxy.cc
    transport.cc
    mnnvl.cc
    allocator.cc
    #sym_kernels.cc
    #dev_runtime.cc
    msccl.cc
    rccl_wrap.cc
    symmetric.cc
)

hipify_files(${LIBSRCFILES_ORIG} ${HIPIFY_DIR} LIBSRCFILES)

# Add compatibility shim if using static cudart
if(CUDARTLIB STREQUAL "cudart_static")
    list(APPEND LIBSRCFILES enhcompat.cc)
endif()

# Configure pkg-config file
#configure_file(
#    ${CMAKE_CURRENT_SOURCE_DIR}/nccl.pc.in
#    ${CMAKE_BINARY_DIR}/lib/pkgconfig/nccl.pc
#    @ONLY
#)

# Add files from subdirectories
add_subdirectory(transport)
add_subdirectory(misc)
add_subdirectory(register)
add_subdirectory(graph)
add_subdirectory(plugin)
add_subdirectory(device)
#add_subdirectory(nccl_device)
add_subdirectory(ras)
#add_subdirectory(scheduler)

add_compile_options(-fmacro-prefix-map=${CMAKE_CURRENT_SOURCE_DIR}/=)

# Add all source files
list(APPEND LIBSRCFILES
    ${TRANSPORT_SOURCES}
    ${MISC_SOURCES}
    ${REGISTER_SOURCES}
    ${GRAPH_SOURCES}
    ${PLUGIN_SOURCES}
    ${RAS_SOURCES}
    ${SYM_SOURCES}
    #${SCHEDULER_SOURCES}
)

hipify_files(${LIBSRCFILES} ${HIPIFY_DIR} LIBSRCFILES_HIPIFIED)
add_custom_target(hipify_all DEPENDS ${LIBSRCFILES_HIPIFIED})


###################### Create a shared NCCL library ############################
add_library(rccl SHARED)

target_sources(rccl PRIVATE ${LIBSRCFILES_HIPIFIED})

# Include directories
target_include_directories(rccl PUBLIC
    ${PROJECT_BINARY_DIR}/include
)
target_include_directories(rccl PRIVATE
    ${HIPIFY_DIR}/src/device
    ${HIPIFY_DIR}/src/include
    ${HIPIFY_DIR}/src/include/plugin
    ${HIPIFY_DIR}/gensrc
    ${HSA_INCLUDE_PATH}
    ${ROCM_SMI_INCLUDE_DIR}
    #${CUDAToolkit_INCLUDE_DIRS}
    #${CUDAToolkit_INCLUDE_DIRS}/cccl
    ${ROCMCORE_PATH}/include
)
if(DEMANGLE_DIR)
  target_include_directories(rccl PRIVATE ${DEMANGLE_DIR})
endif()
if(ROCTX_ENABLE)
  target_include_directories(rccl PRIVATE ${ROCTRACER_INCLUDE_DIR})
endif()

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/include/nccl.h
           ${CMAKE_BINARY_DIR}/include/rccl/rccl.h
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/include
    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/include/rccl
    COMMAND sed -e "s/\\\$$\\{nccl:Major\\}/${NCCL_MAJOR}/g"
                -e "s/\\\$$\\{nccl:Minor\\}/${NCCL_MINOR}/g"
                -e "s/\\\$$\\{nccl:Patch\\}/${NCCL_PATCH}/g"
                -e "s/\\\$$\\{nccl:Suffix\\}/${NCCL_SUFFIX}/g"
                -e "s/\\\$$\\{nccl:Version\\}/${NCCL_VERSION_CODE}/g"
                ${CMAKE_CURRENT_SOURCE_DIR}/nccl.h.in > ${CMAKE_BINARY_DIR}/include/nccl.h
    COMMAND cp ${CMAKE_BINARY_DIR}/include/nccl.h ${CMAKE_BINARY_DIR}/include/rccl/rccl.h
    BYPRODUCTS ${CMAKE_BINARY_DIR}/include/nccl.h
               ${CMAKE_BINARY_DIR}/include/rccl/rccl.h
)

add_custom_target(nccl_header DEPENDS ${CMAKE_BINARY_DIR}/include/nccl.h)
add_custom_target(rccl_header DEPENDS ${CMAKE_BINARY_DIR}/include/rccl/rccl.h)

add_dependencies(rccl nccl_header)
add_dependencies(rccl rccl_header)

# Set version and output name
rocm_setup_version(VERSION ${NCCL_MAJOR}.${NCCL_MINOR}.${NCCL_PATCH})
rocm_set_soversion(rccl "1.0")
#set_target_properties(rccl PROPERTIES
#    VERSION ${NCCL_MAJOR}.${NCCL_MINOR}.${NCCL_PATCH}
#    SOVERSION ${NCCL_MAJOR}
#    OUTPUT_NAME "nccl"
#    PREFIX "lib"
#)

# Set CUDA specific flags
#set_target_properties(rccl PROPERTIES
#    CUDA_SEPARABLE_COMPILATION ON
#    CUDA_RESOLVE_DEVICE_SYMBOLS ON
#    CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}"
#    POSITION_INDEPENDENT_CODE ON
#)

# Link libraries
target_link_libraries(rccl
    PRIVATE
    #nccl_device
    #pthread
    #rt
    dl
    #${CUDAToolkit_LIBRARIES}
    hip::device
    Threads::Threads
    ${EXTRA_LIBS}
)

# Set output directories for nccl shared library
set_target_properties(nccl PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)

###################### Create a ras binary executable ############################
set(RAS_BINSRCFILES ras/client.cc)

add_executable(ncclras ${RAS_BINSRCFILES})

target_include_directories(ncclras PUBLIC
    ${CMAKE_BINARY_DIR}/include
    ${CUDAToolkit_INCLUDE_DIRS}
)

add_dependencies(ncclras nccl_header)

target_link_libraries(ncclras
    PRIVATE
    pthread
    rt
    dl
)

# Set output directory for ncclras executable
set_target_properties(ncclras PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

###################### Create a static NCCL library ############################
add_library(nccl_static STATIC ${LIBSRCFILES})

# Include directories
target_include_directories(nccl_static PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/device
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/include/plugin
    ${CUDAToolkit_INCLUDE_DIRS}
    ${CUDAToolkit_INCLUDE_DIRS}/cccl
)

# Add dependency on nccl_header
add_dependencies(nccl_static nccl_header)

# Link libraries
target_link_libraries(nccl_static
    PRIVATE
    nccl_device
    pthread
    rt
    dl
    ${CUDAToolkit_LIBRARIES}
    ${EXTRA_LIBS}
)

# Set CUDA specific flags
set_target_properties(nccl_static PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
    CUDA_RESOLVE_DEVICE_SYMBOLS ON
    CUDA_ARCHITECTURES "${CMAKE_CUDA_ARCHITECTURES}"
    POSITION_INDEPENDENT_CODE ON
)

# Set output directory for nccl_static library
set_target_properties(nccl_static PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)