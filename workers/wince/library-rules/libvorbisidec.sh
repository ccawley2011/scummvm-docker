get_dependencies automake libtool pkg-config
do_fetch
patch < ../libvorbisidec.diff
autoreconf -i
do_configure --enable-low-accuracy
make -j$num_cpus \
	install-libLTLIBRARIES \
	install-includeHEADERS \
	install-pkgconfigDATA
