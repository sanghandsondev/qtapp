BUILD_DIR := build
CMAKE := cmake
BUILD_TYPE ?= Release
JOBS ?= $(shell nproc)

all: install

install:
	mkdir -p $(BUILD_DIR)
	cd $(BUILD_DIR) && $(CMAKE) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) ..
	$(CMAKE) --build $(BUILD_DIR) -- -j$(JOBS)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: all configure build clean

# rm -rf build
# mkdir build
# cd build
# cmake .. -DCMAKE_PREFIX_PATH="/home/sang/Qt/6.10.0/gcc_64"
# make -j