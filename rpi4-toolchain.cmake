# CMake toolchain file for cross-compiling for Raspberry Pi 4 (64-bit)

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set (CMAKE_SYSROOT $ENV{HOME}/raspberrypi/sysroot)

set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

# Add compile definition for Raspberry Pi builds
add_compile_definitions(RASPBERRY_PI)

# Cấu hình đường dẫn tìm kiếm cho các thư viện và header
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
