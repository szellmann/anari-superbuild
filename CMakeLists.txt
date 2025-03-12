cmake_minimum_required(VERSION 3.7)
set(CMAKE_INSTALL_MESSAGE LAZY)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/dependencies)

if(NOT CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX
      "${CMAKE_BINARY_DIR}/install"
      CACHE STRING "Final install location." FORCE)
endif()

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the build type." FORCE)
endif()
set(CONFIGURATION_TYPES "Debug;Release;RelWithDebInfo")
if (WIN32)
  if (NOT OSPRAY_DEFAULT_CMAKE_CONFIGURATION_TYPES_SET)
    set(CMAKE_CONFIGURATION_TYPES "${CONFIGURATION_TYPES}"
        CACHE STRING "List of generated configurations." FORCE)
    set(OSPRAY_DEFAULT_CMAKE_CONFIGURATION_TYPES_SET ON
        CACHE INTERNAL "Default CMake configuration types set.")
  endif()
else()
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${CONFIGURATION_TYPES})
endif()
if (NOT DEPENDENCIES_BUILD_TYPE)
  set(DEPENDENCIES_BUILD_TYPE Release)
endif()

include(add_dependency.cmake)

## Establish project ##

project(ANARI_superbuild)

include(ExternalProject)
include(GNUInstallDirs)
include(ProcessorCount)
include(CMakeDependentOption)

## Superbuild options ##

ProcessorCount(PROCESSOR_COUNT)

if(NOT PROCESSOR_COUNT EQUAL 0)
  set(BUILD_JOBS ${PROCESSOR_COUNT} CACHE STRING "Number of build jobs '-j <n>'")
else()
  set(BUILD_JOBS 4 CACHE STRING "Number of build jobs '-j <n>'")
endif()

option(ALWAYS_REBUILD "Force every project to always be rebuilt?" OFF)

option(BUILD_LATEST "Build the latest (and next_release) versions of all libraries" OFF)

option(WITH_CUDA "Build CUDA-dependent devices and tools" OFF)

## Setup top-level variables ##

set(installDir ${CMAKE_INSTALL_PREFIX})

get_filename_component(INSTALL_DIR_ABSOLUTE
  ${installDir} ABSOLUTE BASE_DIR ${CMAKE_CURRENT_BINARY_DIR})

if (${CMAKE_VERSION} VERSION_GREATER 3.11.4)
  set(PARALLEL_JOBS_OPTS -j ${BUILD_JOBS})
endif()

## Build dependencies ##
set(DEFAULT_BUILD_COMMAND ${CMAKE_COMMAND} --build . --config ${DEPENDENCIES_BUILD_TYPE} ${PARALLEL_JOBS_OPTS})

## Add repos ##

# anari_sdk

option(BUILD_HELIDE "Build helide device along with SDK" ON)
option(BUILD_REMOTE "Build remote device along with SDK" OFF)
option(BUILD_SINK "Build remote device along with SDK" OFF)
option(BUILD_ANARI_VIEWER "Build example viewer along with SDK" OFF) # TODO: glfw dep!
option(BUILD_ANARI_SDK "Build ANARK-SDK or use one in existing environment?" ON)
if (BUILD_ANARI_SDK)
  set(anari_sdk_REPOSITORY "https://github.com/KhronosGroup/ANARI-SDK.git")
  set(anari_sdk_HASH_STABLE "1d5d569aeda0fbb3f31dd6bb5d7a3a8ed4de04d4")
  set(anari_sdk_HASH_LATEST "origin/next_release")
  set(anari_sdk_CMAKE_ARGS
    -DBUILD_HELIDE_DEVICE=${BUILD_HELIDE}
    -DBUILD_REMOTE_DEVICE=${BUILD_REMOTE}
    -DBUILD_SINK_DEVICE=${BUILD_SINK}
    -DBUILD_VIEWER=${BUILD_ANARI_VIEWER}
    -DINSTALL_VIEWER=${BUILD_ANARI_VIEWER}
  )
  add_dependency(anari_sdk)
endif()

# visionaray

option(BUILD_VISIONARAY "Build visionaray for anari-visionaray device or use one in existing environment?" ON)
if (BUILD_VISIONARAY)
  set(visionaray_REPOSITORY "https://github.com/szellmann/visionaray.git")
  set(visionaray_HASH_STABLE "v0.5.0")
  set(visionaray_HASH_LATEST "origin/master")
  set(visionaray_CMAKE_ARGS
    -DVSNRAY_ENABLE_CUDA=OFF
    -DVSNRAY_ENABLE_COMMON=OFF
    -DVSNRAY_ENABLE_EXAMPLES=OFF
    -DVSNRAY_ENABLE_VIEWER=OFF
  )
  add_dependency(visionaray)
endif()

# anari_visionaray

option(BUILD_ANARI_VISIONARAY "Build anari-visionaray as a part of the superbuild." ON)
if (BUILD_ANARI_VISIONARAY)
  set(anari_visionaray_REPOSITORY "https://github.com/szellmann/anari-visionaray.git")
  set(anari_visionaray_HASH_STABLE "199046a9512d09c31f8a78607164377613e59ed7")
  set(anari_visionaray_HASH_LATEST "origin/main")
  set(anari_visionaray_CMAKE_ARGS
    -DANARI_VISIONARAY_ENABLE_CUDA=OFF
    -DANARI_VISIONARAY_ENABLE_HIP=OFF
    -DANARI_VISIONARAY_ENABLE_VIEWER=OFF
  )
  set(anari_visionaray_DEPENDENCIES anari_sdk visionaray)
  add_dependency(anari_visionaray)
endif()

# visrtx

option(BUILD_VISRTX "When building VisRTX, include the visrtx device" ON)
option(VISRTX_BUILD_RTX_DEVICE "When building VisRTX, include the visrtx device" ON)
option(VISRTX_BUILD_GL_DEVICE "When building VisRTX, include the visgl device" ON)
option(VISRTX_BUILD_TSD "When building VisRTX, include TSD" ON)
if (BUILD_VISRTX)
  set(visrtx_REPOSITORY "https://github.com/NVIDIA/VisRTX")
  set(visrtx_HASH_STABLE "ac8d9a449f0f4ba3400b75fadfb22e4f8223c98e")
  set(visrtx_HASH_LATEST "origin/next_release")
  if (APPLE)
    # VisGL does not work on Mac OSX:
    if (VISRTX_BUILD_GL_DEVICE)
      message("NOT building VisGL device on macOS")
      set(VISRTX_BUILD_GL_DEVICE OFF)
    endif()
  endif()

  if (NOT WITH_CUDA)
    # No OptiX on Mac OSX:
    if (VISRTX_BUILD_RTX_DEVICE)
      message("NOT building VisRTX device on macOS")
      set(VISRTX_BUILD_RTX_DEVICE OFF)
    endif()
  endif()

  if (VISRTX_BUILD_RTX_DEVICE)
    message("NOT building VisRTX for now (for lack of OptiX headers")
    set(VISRTX_BUILD_RTX_DEVICE OFF)
  endif()

  set(visrtx_CMAKE_ARGS
    -DVISRTX_BUILD_RTX_DEVICE=${VISRTX_BUILD_RTX_DEVICE}
    -DVISRTX_BUILD_GL_DEVICE=${VISRTX_BUILD_GL_DEVICE}
    -DVISRTX_BUILD_TSD=${VISRTX_BUILD_TSD}
    -DTSD_USE_ASSIMP=OFF
    -DTSD_USE_CUDA=${WITH_CUDA}
    -DTSD_USE_HDF5=OFF
    -DTSD_USE_TBB=OFF
  )
  set(visrtx_DEPENDENCIES anari_sdk)
  add_dependency(visrtx)
endif()

# ospray

option(BUILD_OSPRAY "Build ospray for anari-ospray device or use one in existing environment?" ON)
if (BUILD_OSPRAY)
  set(ospray_REPOSITORY "https://github.com/RenderKit/ospray.git")
  set(ospray_HASH_STABLE "85af2929937d516997451cbd52d352cf93125ed2")
  set(ospray_HASH_LATEST "origin/devel")
  if (APPLE)
    # no arm64 packages for Mac - build these from sourde:
    set(OSPRAY_BUILD_TBB_FROM_SOURCE ON)
    set(OSPRAY_BUILD_OPENVKL_FROM_SOURCE ON)
  else()
    set(OSPRAY_BUILD_TBB_FROM_SOURCE OFF)
    set(OSPRAY_BUILD_OPENVKL_FROM_SOURCE OFF)
  endif()
  set(ospray_SOURCE_SUBDIR scripts/superbuild)
  set(ospray_NO_INSTALL TRUE)
  set(ospray_CMAKE_ARGS
    -DINSTALL_IN_SEPARATE_DIRECTORIES=OFF
    -DDEPENDENCIES_BUILD_TYPE=${DEPENDENCIES_BUILD_TYPE}
    -DBUILD_TBB_FROM_SOURCE:BOOL=${OSPRAY_BUILD_TBB_FROM_SOURCE}
    -DBUILD_OPENVKL_FROM_SOURCE:BOOL=${OSPRAY_BUILD_OPENVKL_FROM_SOURCE}
  )
  add_dependency(ospray)
endif()

# anari_ospray

option(BUILD_ANARI_OSPRAY "Build anari-ospray as a part of the superbuild." ON)
if (BUILD_ANARI_OSPRAY)
  set(anari_ospray_REPOSITORY "https://github.com/szellmann/anari-ospray.git") # TODO: this is *my* fork!
  set(anari_ospray_HASH_STABLE "cd711779ba8233952d6dbe44ec9060eecbd252b8") # TODO: this is on *my* fork!
  set(anari_ospray_HASH_LATEST "origin/helium_object_finalization") # TODO: this is on *my* fork!
  set(anari_ospray_DEPENDENCIES anari_sdk ospray)
  add_dependency(anari_ospray)
endif()

# pynari

option(BUILD_PYNARI "Build pynari python bindings." ON)
if (BUILD_PYNARI)
  set(pynari_REPOSITORY "https://github.com/ingowald/pynari.git")
  set(pynari_HASH_STABLE "c0801d030ac4bfe8dea37df5a41e01a945821099") # on devel
  set(pynari_HASH_LATEST "origin/devel")
  set(pynari_DEPENDENCIES anari_sdk)
  add_dependency(pynari)
endif()
