# This is just to illustrate how CMake works, to those who don't know how to use it.
# It's not a good practice to ship a Makefile like this one.

all: clean
	mkdir build
	cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make
	mv ./build/risiko .

.PHONY: clean
clean:
	-rm -rf build
	-unlink risiko
