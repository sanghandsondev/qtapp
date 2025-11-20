# BUILD_DIR := build
# CMAKE := cmake
# BUILD_TYPE ?= Release
# JOBS ?= $(shell nproc)

all: install

install: clean
	mkdir -p build
	cd build && cmake \
		-DCMAKE_PREFIX_PATH="/home/sang/Qt/6.10.0/gcc_64" ..
	cd build && make

# deploy: clean
# 	mkdir -p build
# 	cd build && cmake \
# 		-DCMAKE_TOOLCHAIN_FILE=../rpi4_toolchain.cmake \
# 		-DCMAKE_PREFIX_PATH="$(CMAKE_SYSROOT)/usr/local/qt6" \
# 		-DQT_HOST_PATH="/home/sang/Qt/6.10.0/gcc_64" \
# 		-DRPI_BUILD=ON \
# 		..
# 	cd build && make
# 	./deploy.sh

setenv:
	./setenv.sh

clean:
	rm -rf build

.PHONY: all install setenv clean