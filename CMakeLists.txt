# Yêu cầu phiên bản CMake tối thiểu
cmake_minimum_required(VERSION 3.16)

# Tên dự án và ngôn ngữ
project(QmlBasicApp LANGUAGES CXX)

# Thiết lập chuẩn C++ (Qt 6 khuyến nghị C++17 trở lên)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Tìm kiếm các gói Qt 6 cần thiết
find_package(Qt6 REQUIRED COMPONENTS Quick Qml WebSockets)

# Add executable
add_executable(QmlBasicApp
    main.cpp
)

# Compile Qt resource (main.qrc) and add to the target
qt_add_resources(QML_RESOURCES main.qrc)
target_sources(QmlBasicApp PRIVATE ${QML_RESOURCES})

target_link_libraries(QmlBasicApp PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::WebSockets
)

# Optional: ensure C++ standard is set (kept from top of file)