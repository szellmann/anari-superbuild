ANARI superbuild
================

Work in progress -- build the SDK plus devices and other tools and install to
`${CMAKE_INSTALL_PREFIX}`

### CMake options:

ANARI SDK:
- `BUILD_ANARI_SDK`: "Build ANARK-SDK or use one in existing environment?"
- `BUILD_HELIDE` "Build helide device along with SDK"
- `BUILD_REMOTE` "Build remote device along with SDK" (default: off b/c of build issues)
- `BUILD_SINK` "Build remote device along with SDK" (default: off)
- `BUILD_ANARI_VIEWER` "Build example viewer along with SDK" (default: off)

Devices:
- `BUILD_ANARI_VISIONARAY`: "Build anari-visionaray as a part of the superbuild"
- `BUILD_ANARI_OSPRAY` "Build anari-ospray as a part of the superbuild"

Apps:

Dependencies:
- `BUILD_VISIONARAY` "Build visionaray for anari-visionaray device or use one in existing environment?"
- `BUILD_OSPRAY` "Build ospray for anari-ospray device or use one in existing environment?" (uses OSPRay's superbuild)
