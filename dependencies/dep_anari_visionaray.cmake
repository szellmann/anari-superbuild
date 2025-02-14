set(COMPONENT_NAME anari_visionaray)

set(COMPONENT_PATH ${CMAKE_INSTALL_PREFIX})

if (TRUE)
  ExternalProject_Add(${COMPONENT_NAME}
    PREFIX ${COMPONENT_NAME}
    GIT_REPOSITORY https://github.com/szellmann/anari-visionaray.git
    GIT_TAG ${ANARI_VISIONARAY_HASH}
    STAMP_DIR ${COMPONENT_NAME}/stamp
    SOURCE_DIR ${COMPONENT_NAME}/src
    BINARY_DIR ${COMPONENT_NAME}/build
    LIST_SEPARATOR | # Use the alternate list separator
    CMAKE_ARGS
      -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
      -DCMAKE_INSTALL_PREFIX:PATH=${COMPONENT_PATH}
      -DCMAKE_INSTALL_INCLUDEDIR=${CMAKE_INSTALL_INCLUDEDIR}
      -DCMAKE_INSTALL_LIBDIR=${CMAKE_INSTALL_LIBDIR}
      -DCMAKE_INSTALL_DOCDIR=${CMAKE_INSTALL_DOCDIR}
      -DCMAKE_INSTALL_BINDIR=${CMAKE_INSTALL_BINDIR}
      -DANARI_VISIONARAY_ENABLE_CUDA=${ANARI_VISIONARAY_WITH_CUDA}
      -DANARI_VISIONARAY_ENABLE_HIP=${ANARI_VISIONARAY_WITH_HIP}
      -DANARI_VISIONARAY_ENABLE_VIEWER=OFF
      $<$<BOOL:${BUILD_ANARI_SDK}>:-Danari_DIR=${ANARI_SDK_PATH}>
      $<$<BOOL:${BUILD_VISIONARAY}>:-Dvisionaray_DIR=${VISIONARAY_PATH}>
    BUILD_COMMAND ${DEFAULT_BUILD_COMMAND}
    BUILD_ALWAYS ${ALWAYS_REBUILD}
  )

  if (BUILD_ANARI_SDK)
    ExternalProject_Add_StepDependencies(${COMPONENT_NAME} configure anari_sdk)
  endif()

  if (BUILD_VISIONARAY)
    ExternalProject_Add_StepDependencies(${COMPONENT_NAME} configure visionaray)
  endif()
endif()
