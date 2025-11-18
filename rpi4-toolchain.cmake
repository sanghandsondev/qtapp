# # CMake toolchain file for cross-compiling for Raspberry Pi 4 (64-bit)

# # Tên hệ điều hành mục tiêu
# set(CMAKE_SYSTEM_NAME Linux)
# set(CMAKE_SYSTEM_PROCESSOR aarch64)

# # Đường dẫn đến sysroot trên máy host của bạn.
# # THAY THẾ ĐƯỜNG DẪN NÀY bằng đường dẫn thực tế đến sysroot của bạn.
# set(CMAKE_SYSROOT /path/to/your/rpi/sysroot)

# # Chỉ định trình biên dịch chéo
# set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
# set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

# # Cấu hình đường dẫn tìm kiếm cho các thư viện và header
# set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
# set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
# set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
