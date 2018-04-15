get_dependencies g++
do_fetch

if [ "`which b2`" = "" ]; then
	cd tools/build
	./bootstrap.sh
	./b2 install --prefix=/usr/local
	cd ../..
fi

echo "using gcc : : $host-g++ ;" > user-config.jam
b2 --prefix=/usr/$host \
	--build-dir=/tmp/boost-build/$host \
	--user-config=user-config.jam \
	--with-program_options \
	toolset=gcc-mingw \
	target-os=windows \
	link=static \
	variant=release \
	stage \
	install
