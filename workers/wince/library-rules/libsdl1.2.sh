#do_fetch
#do_configure
get_dependencies ca-certificates wget
wget -O - http://libsdl.org/release/SDL-1.2.6.tar.gz |tar zxf -
cd SDL-*/
wget -O - http://pocketinsanity.org/scummvm/libraries/SDL-1.2.6-wince.patch | patch -p1
patch -p0 < ../libsdl1.2.diff
make -j$(nproc || grep -c ^processor /proc/cpuinfo || echo 1)
cp -r libSDL.a /opt/mingw32ce/arm-mingw32ce/lib/
cp -r include /opt/mingw32ce/arm-mingw32ce/include/SDL
