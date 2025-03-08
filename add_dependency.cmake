macro(__ExternalProject_Add_INSTALL component_name no_install)
  if (${no_install})
    ExternalProject_Add(${component_name} INSTALL_COMMAND "" ${ARGN})
  else()
    ExternalProject_Add(${component_name} ${ARGN})
  endif()
endmacro()

macro(add_dependency)
  set(COMPONENT_NAME ${ARGV0})
  set(COMPONENT_PATH ${CMAKE_INSTALL_PREFIX})

  if (BUILD_LATEST)
    set(HASH ${${COMPONENT_NAME}_HASH_LATEST})
  else()
    set(HASH ${${COMPONENT_NAME}_HASH_STABLE})
  endif()

  __ExternalProject_Add_INSTALL(${COMPONENT_NAME}
    ${COMPONENT_NAME}_NO_INSTALL
    PREFIX ${COMPONENT_NAME}
    GIT_REPOSITORY ${${COMPONENT_NAME}_REPOSITORY}
    GIT_TAG ${HASH}
    STAMP_DIR ${COMPONENT_NAME}/stamp
    SOURCE_DIR ${COMPONENT_NAME}/src
    BINARY_DIR ${COMPONENT_NAME}/build
    SOURCE_SUBDIR ${${COMPONENT_NAME}_SOURCE_SUBDIR}
    LIST_SEPARATOR | # Use the alternate list separator
    CMAKE_ARGS
      -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
      -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
      -DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
      -DCMAKE_INSTALL_PREFIX:PATH=${COMPONENT_PATH}
      -DCMAKE_INSTALL_INCLUDEDIR=${CMAKE_INSTALL_INCLUDEDIR}
      -DCMAKE_INSTALL_LIBDIR=${CMAKE_INSTALL_LIBDIR}
      -DCMAKE_INSTALL_DOCDIR=${CMAKE_INSTALL_DOCDIR}
      -DCMAKE_INSTALL_BINDIR=${CMAKE_INSTALL_BINDIR}
      ${${COMPONENT_NAME}_CMAKE_ARGS}
    BUILD_COMMAND ${DEFAULT_BUILD_COMMAND}
    BUILD_ALWAYS ${ALWAYS_REBUILD}
  )

  # Step dependencies:
  if (DEFINED ${COMPONENT_NAME}_DEPENDENCIES)
    ExternalProject_Add_StepDependencies(${COMPONENT_NAME}
      configure ${${COMPONENT_NAME}_DEPENDENCIES})
  endif()

  # Add to prefix path, set xxx_PATH to use as a dependency:
  set(${COMPONENT_NAME}_PATH "${COMPONENT_PATH}")
  list(APPEND CMAKE_PREFIX_PATH ${COMPONENT_PATH})
  string(REPLACE ";" "|" CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
endmacro()
