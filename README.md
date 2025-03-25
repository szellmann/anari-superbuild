ANARI superbuild
================

Work in progress -- build the SDK plus devices and other tools and install to
`${CMAKE_INSTALL_PREFIX}`

### Status (Nightly Builds at 5:30am UTC):

[![CI](https://github.com/szellmann/anari-superbuild/actions/workflows/anari-superbuild-ci.yml/badge.svg?event=schedule)](https://github.com/szellmann/anari-superbuild/actions/workflows/anari-superbuild-ci.yml)

### CMake options:

`BUILD_LATEST`: (default: off) if set, the latest unstable branches will be
  used. This, e.g., is the behavior for CI nightly builds; otherwise a (known)
  stable configuration will be used.

ANARI SDK:
- `BUILD_ANARI_SDK`: "Build ANARK-SDK or use one in existing environment?"
- `BUILD_HELIDE` "Build helide device along with SDK"
- `BUILD_REMOTE` "Build remote device along with SDK" (default: off b/c of build issues)
- `BUILD_SINK` "Build remote device along with SDK" (default: off)
- `BUILD_ANARI_VIEWER` "Build example viewer along with SDK" (default: off)

Devices:
- `BUILD_ANARI_OSPRAY` "Build anari-ospray as a part of the superbuild"
- `BUILD_ANARI_VISIONARAY`: "Build anari-visionaray as a part of the superbuild"
- `BUILD_VISRTX`: "Build VisRTX as a part of the superbuild"

Device-specific options:
- `VISRTX_BUILD_RTX_DEVICE`: "When building VisRTX, include the visrtx device"
- `VISRTX_BUILD_GL_DEVICE`: "When building VisRTX, include the visgl device"
- `VISRTX_BUILD_TSD`: "When building VisRTX, include TSD"

Apps:
- `BUILD_PYNARI` "Build pynari python bindings"

Dependencies:
- `BUILD_OSPRAY` "Build ospray for anari-ospray device or use one in existing environment?" (uses OSPRay's superbuild)
- `BUILD_VISIONARAY` "Build visionaray for anari-visionaray device or use one in existing environment?"
