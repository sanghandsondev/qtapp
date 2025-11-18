BUILD_DIR := build
CMAKE := cmake
BUILD_TYPE ?= Release
JOBS ?= $(shell nproc)

# Cấu hình cho Raspberry Pi
# RPI_HOST := pi@your_pi_ip_address
# RPI_DEST_DIR := /home/pi/qtapp
# RPI_BUILD_DIR := build-rpi
# RPI_TOOLCHAIN_FILE := rpi4-toolchain.cmake

all: install

install: clean
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && $(CMAKE) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_PREFIX_PATH="/home/sang/Qt/6.10.0/gcc_64" ..
	$(CMAKE) --build $(BUILD_DIR) -- -j$(JOBS)

# build-rpi:
# 	mkdir -p $(RPI_BUILD_DIR)
# 	cd $(RPI_BUILD_DIR) && $(CMAKE) \
# 		-DCMAKE_TOOLCHAIN_FILE=../$(RPI_TOOLCHAIN_FILE) \
# 		-DCMAKE_BUILD_TYPE=$(BUILD_TYPE) \
# 		-DCMAKE_PREFIX_PATH="$(CMAKE_SYSROOT)/usr/lib/aarch64-linux-gnu/cmake" \
# 		-DQT_HOST_PATH="/home/sang/Qt/6.10.0/gcc_64" \
# 		-DRPI_BUILD=ON \
# 		..
# 	$(CMAKE) --build $(RPI_BUILD_DIR) -- -j$(JOBS)

# deploy: build-rpi
# 	@echo ">>> Deploying to Raspberry Pi at $(RPI_HOST)"
# 	ssh $(RPI_HOST) "mkdir -p $(RPI_DEST_DIR)"
# 	scp $(RPI_BUILD_DIR)/qtapp $(RPI_HOST):$(RPI_DEST_DIR)/
# 	@echo ">>> Deployment finished."

clean:
# 	rm -rf $(BUILD_DIR) $(RPI_BUILD_DIR)
	rm -rf build

# .PHONY: all install build-rpi deploy clean
.PHONY: all install clean