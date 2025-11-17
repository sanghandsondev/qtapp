cmake_minimum_required(VERSION 3.16)

project(QtApp LANGUAGES CXX)

# QT 6 requires at least C++17
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find the Qt6 packages
find_package(Qt6 REQUIRED COMPONENTS Quick Qml WebSockets)

# Add executable
add_executable(QtApp
    main.cpp
)

# Enable automatic MOC, UIC, and RCC
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# Compile Qt resource (main.qrc) and add to the target
qt_add_resources(QML_RESOURCES main.qrc)

target_sources(QtApp PRIVATE ${QML_RESOURCES})

target_link_libraries(QtApp PRIVATE
    Qt6::Quick
    Qt6::Qml
    Qt6::WebSockets
)
