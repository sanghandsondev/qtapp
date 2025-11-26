cmake_minimum_required(VERSION 3.16)

project(QtApp LANGUAGES CXX)

# --- Project Settings ---
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

# --- Find Qt Packages ---
find_package(Qt6 REQUIRED COMPONENTS Gui Quick Qml WebSockets Multimedia)

qt_policy(SET QTP0001 NEW)

# --- Project Sources ---
# Automatically find all .cpp files in the src directory
file(GLOB_RECURSE SOURCES "src/*.cpp")

# --- Target Definition ---
qt_add_executable(QtApp ${SOURCES})

# --- Add build definition for Raspberry Pi ---
if(CMAKE_SYSTEM_PROCESSOR STREQUAL "aarch64")
    target_compile_definitions(QtApp PRIVATE RASPBERRYPI_BUILD)
    message(STATUS "Raspberry Pi build detected. RASPBERRYPI_BUILD is defined.")
endif()

# --- QML Resources ---
file(GLOB QML_FILES CONFIGURE_DEPENDS RELATIVE 
    "${CMAKE_CURRENT_SOURCE_DIR}" 
    "qml/*.qml"
    "qml/PageView/*.qml"
    "qml/Components/*.qml"
)

qt_add_resources(QtApp qml_resources
    PREFIX "/"
    FILES ${QML_FILES} assets/fonts/ttf/material-symbols-rounded-latin-500-normal.ttf
)

# --- Target Linking ---
target_link_libraries(QtApp PRIVATE
    Qt6::Gui
    Qt6::Quick
    Qt6::Qml
    Qt6::WebSockets
    Qt6::Multimedia
)

# --- Installation ---
install(TARGETS QtApp
    RUNTIME DESTINATION /usr/local/bin
)