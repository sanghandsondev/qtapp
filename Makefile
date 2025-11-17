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

# rebuild: clean all

# run: build
# 	./$(BUILD_DIR)/QmlBasicApp

# run_offscreen: build
# 	QT_QPA_PLATFORM=offscreen ./$(BUILD_DIR)/QmlBasicApp

# run_xvfb: build
# 	xvfb-run -s "-screen 0 1024x768x24" ./$(BUILD_DIR)/QmlBasicApp

# help:
# 	@echo "Usage: make [target]"
# 	@echo "Targets:" \
# 		&& echo "  all (default)    - configure and build" \
# 		&& echo "  configure        - run cmake configure" \
# 		&& echo "  build            - build the project" \
# 		&& echo "  run              - run binary" \
# 		&& echo "  run_offscreen    - run with QT_QPA_PLATFORM=offscreen" \
# 		&& echo "  run_xvfb         - run inside Xvfb (requires xvfb-run)" \
# 		&& echo "  clean            - remove build dir" \
# 		&& echo "  rebuild          - clean + all" \
# 		&& echo "Variables: BUILD_TYPE (default Release), JOBS (default nproc)"
