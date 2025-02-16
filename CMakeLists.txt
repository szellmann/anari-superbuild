cmake_minimum_required(VERSION 3.7)
set(CMAKE_INSTALL_MESSAGE LAZY)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/dependencies)

if(NOT CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX
      "${CMAKE_BINARY_DIR}/install"
      CACHE STRING "Final install location." FORCE)
endif()

if (NOT DEPENDENCIES_BUILD_TYPE)
  set(DEPENDENCIES_BUILD_TYPE Release)
endif()

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

option(BUILD_ANARI_SDK "Build ANARK-SDK or use one in existing environment?" ON)
if (BUILD_ANARI_SDK)
  set(ANARI_SDK_HASH "565f458481230299988c887a323fdd2e599c79e1") # next_release
endif()

option(BUILD_HELIDE "Build helide device along with SDK" ON)
if (BUILD_HELIDE)
  if (NOT BUILD_ANARI_SDK)
    message(WARNING "Disabling BUILD_HELIDE as we do not build the SDK!")
    set(BUILD_HELIDE OFF)
  endif()
  set(ANARI_SDK_BUILD_HELIDE_DEVICE ${BUILD_HELIDE})
endif()

option(BUILD_REMOTE "Build remote device along with SDK" OFF)
if (BUILD_REMOTE)
  if (NOT BUILD_ANARI_SDK)
    message(WARNING "Disabling BUILD_REMOTE as we do not build the SDK!")
    set(BUILD_REMOTE OFF)
  endif()
  set(ANARI_SDK_BUILD_REMOTE_DEVICE ${BUILD_REMOTE})
endif()

option(BUILD_SINK "Build remote device along with SDK" OFF)
if (BUILD_SINK)
  if (NOT BUILD_ANARI_SDK)
    message(WARNING "Disabling BUILD_SINK as we do not build the SDK!")
    set(BUILD_SINK OFF)
  endif()
  set(ANARI_SDK_BUILD_SINK_DEVICE ${BUILD_SINK})
endif()

option(BUILD_ANARI_VIEWER "Build example viewer along with SDK" OFF) # TODO: glfw dep!
if (BUILD_ANARI_VIEWER)
  if (NOT BUILD_ANARI_SDK)
    message(WARNING "Disabling BUILD_ANARI_VIEWER as we do not build the SDK!")
    set(BUILD_ANARI_VIEWER OFF)
  endif()
  set(ANARI_SDK_BUILD_VIEWER ${BUILD_ANARI_VIEWER})
endif()

option(BUILD_VISIONARAY "Build visionaray for anari-visionaray device or use one in existing environment?" ON)
if (BUILD_VISIONARAY)
  set(VISIONARAY_HASH "bf3409d33c3590d0735d7cc99b1527dc2f1da08f")
  set(VISIONARAY_WITH_CUDA OFF)
endif()

option(BUILD_ANARI_VISIONARAY "Build anari-visionaray as a part of the superbuild." ON)
if (BUILD_ANARI_VISIONARAY)
  set(ANARI_VISIONARAY_HASH "f778e02760d320ff6008052ea8656bccc3d834e8")
  set(ANARI_VISIONARAY_WITH_CUDA OFF)
  set(ANARI_VISIONARAY_WITH_HIP OFF)
endif()

option(BUILD_OSPRAY "Build ospray for anari-ospray device or use one in existing environment?" ON)
if (BUILD_OSPRAY)
  set(OSPRAY_HASH "85af2929937d516997451cbd52d352cf93125ed2")
  if (APPLE)
    # no arm64 packages for Mac - build these from sourde:
    set(OSPRAY_BUILD_TBB_FROM_SOURCE ON)
    set(OSPRAY_BUILD_OPENVKL_FROM_SOURCE ON)
  else()
    set(OSPRAY_BUILD_TBB_FROM_SOURCE OFF)
    set(OSPRAY_BUILD_OPENVKL_FROM_SOURCE OFF)
  endif()
endif()

option(BUILD_ANARI_OSPRAY "Build anari-ospray as a part of the superbuild." ON)
if (BUILD_ANARI_OSPRAY)
  set(ANARI_OSPRAY_HASH "0c83c53c55e41483b018dfbaf2270c82304949da") # TODO: this is on *my* fork!
endif()

option(BUILD_PYNARI "Build pynari python bindings." ON)
if (BUILD_PYNARI)
  set(PYNARI_HASH "c0801d030ac4bfe8dea37df5a41e01a945821099") # devel
endif()


## Setup top-level variables ##

set(installDir ${CMAKE_INSTALL_PREFIX})

get_filename_component(INSTALL_DIR_ABSOLUTE
  ${installDir} ABSOLUTE BASE_DIR ${CMAKE_CURRENT_BINARY_DIR})

if (${CMAKE_VERSION} VERSION_GREATER 3.11.4)
  set(PARALLEL_JOBS_OPTS -j ${BUILD_JOBS})
endif()

## Build dependencies ##
set(DEFAULT_BUILD_COMMAND ${CMAKE_COMMAND} --build . --config ${DEPENDENCIES_BUILD_TYPE} ${PARALLEL_JOBS_OPTS})


if (BUILD_ANARI_SDK)
  include(dep_anari_sdk)
endif()

if (BUILD_VISIONARAY)
  include(dep_visionaray)
endif()

if (BUILD_ANARI_VISIONARAY)
  include(dep_anari_visionaray)
endif()

if (BUILD_OSPRAY)
  include(dep_ospray)
endif()

if (BUILD_ANARI_OSPRAY)
  include(dep_anari_ospray)
endif()

if (BUILD_PYNARI)
  include(dep_pynari)
endif()
