all: install

install: clean
	mkdir -p build
	cd build && cmake \
		-DCMAKE_PREFIX_PATH="/home/sang/Qt/6.10.1/gcc_64" ..
	cd build && make && make install

# No cross-compiler
deploy:
	./deploy.sh

cross: clean
	mkdir -p build
	cd build && cmake \
		-DCMAKE_PREFIX_PATH="/home/pi/Qt/6.10.1/gcc_arm64" ..
	cd build && make && make install

clean:
	rm -rf build

.PHONY: all install setenv cross clean