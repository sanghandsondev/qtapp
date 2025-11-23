# #!/bin/bash

# set -e

# QT_VERSION="6.10.0"
# QT_SOURCE_DIR="$HOME/qt-source/qt-everywhere-src-${QT_VERSION}"
# QT_BUILD_DIR="$HOME/qt-build/rpi4_aarch64"
# QT_INSTALL_DIR="$HOME/Qt/${QT_VERSION}/rpi_aarch64"
# SYSROOT_PATH="$HOME/raspberrypi/sysroot"

# echo ">>> [1/5] Downloading Qt ${QT_VERSION} source..."
# mkdir -p "$HOME/qt-source"
# cd "$HOME/qt-source"
# if [ ! -d "$QT_SOURCE_DIR" ]; then
#     wget -q https://download.qt.io/official_releases/qt/${QT_VERSION%.*}/${QT_VERSION}/single/qt-everywhere-src-${QT_VERSION}.tar.xz
#     tar -xf qt-everywhere-src-${QT_VERSION}.tar.xz
#     rm qt-everywhere-src-${QT_VERSION}.tar.xz
# fi

# echo ">>> [2/5] Creating build directory..."
# mkdir -p "$QT_BUILD_DIR"
# cd "$QT_BUILD_DIR"

# echo ">>> [3/5] Configuring Qt for Raspberry Pi 4 (aarch64) with CMake..."
# cmake -S "$QT_SOURCE_DIR" -B "$QT_BUILD_DIR" \
#     -G Ninja \
#     -DCMAKE_INSTALL_PREFIX="$QT_INSTALL_DIR" \
#     -DCMAKE_TOOLCHAIN_FILE="/home/sang/sangank/qtapp/rpi4_toolchain.cmake" \
#     -DQT_HOST_PATH="/home/sang/Qt/6.10.0/gcc_64" \
#     -DQT_BUILD_EXAMPLES=OFF \
#     -DQT_BUILD_TESTS=OFF \
#     -DBUILD_qtwebengine=OFF \
#     -DBUILD_qttools=OFF \
#     -DBUILD_qtdoc=OFF \
#     -DBUILD_qttranslations=OFF \
#     -DBUILD_qtwebview=OFF \
#     -DBUILD_qtopcua=OFF \
#     -DBUILD_qtmqtt=OFF \
#     -DBUILD_qtvirtualkeyboard=OFF \
#     -DBUILD_qtscxml=OFF \
#     -DBUILD_qtsensors=OFF \
#     -DBUILD_qtserialbus=OFF \
#     -DBUILD_qtspeech=OFF \
#     -DBUILD_qtwayland=OFF \
#     -DBUILD_qtdatavis3d=OFF \
#     -DBUILD_qtcoap=OFF \
#     -DBUILD_qthttpserver=OFF \
#     -DBUILD_qtnetworkauth=OFF \
#     -DBUILD_qtconnectivity=OFF \
#     -DBUILD_qtactiveqt=OFF \
#     -DBUILD_qt3d=OFF \
#     -DBUILD_qt5compat=OFF \
#     -DBUILD_qtgraphs=OFF \
#     -DBUILD_qtgrpc=OFF \
#     -DBUILD_qtserialport=OFF \
#     -DBUILD_qtpositioning=OFF \
#     -DBUILD_qtlocation=OFF \
#     -DBUILD_qtlottie=OFF \
#     -DBUILD_qtquick3dphysics=OFF \
#     -DBUILD_qtquickeffectmaker=OFF \
#     -DBUILD_qtremoteobjects=OFF \
#     -DQT_QPA_DEFAULT_PLATFORM=eglfs

# echo ">>> [4/5] Building Qt (this may take 30-60 minutes)..."
# cmake --build . -j$(nproc)

# echo ">>> [5/5] Installing Qt..."
# cmake --install .

# echo ">>> Done! Qt ${QT_VERSION} has been cross-compiled and installed to:"
# echo ">>> ${QT_INSTALL_DIR}"
# echo ">>> "
# echo ">>> You can now use this Qt path in your CMake build:"
# echo ">>> -DCMAKE_PREFIX_PATH=\"${QT_INSTALL_DIR}\""
