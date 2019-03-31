ARG DEFAULT_BASE_IMAGE
ARG DEFAULT_OS_IMAGE
FROM ${DEFAULT_OS_IMAGE} AS compiler
USER root
ARG WORKER_NAME

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		bison \
		build-essential \
		bzip2 \
		ca-certificates \
		file \
		flex \
		libcloog-isl-dev \
		libisl-dev \
		libmpc-dev \
		libmpfr-dev \
		pkg-config \
		texinfo \
		wget \
		unzip \
		zlib1g-dev \
		&& \
	rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/compile
ARG GCC_VER=7.3.0
RUN wget --progress=bar:force:noscroll -O gcc-ce-$GCC_VER.zip \
		https://github.com/MaxKellermann/gcc/archive/ce-$GCC_VER.zip \
		&& unzip gcc-ce-$GCC_VER.zip \
		&& rm -rf gcc-ce-$GCC_VER.zip \
		&& mkdir -p gcc-ce-$GCC_VER/winsup
ARG BINUTILS_VER=2.30
RUN wget --progress=bar:force:noscroll -O binutils-gdb-ce-$BINUTILS_VER.zip \
		https://github.com/MaxKellermann/binutils-gdb/archive/ce-$BINUTILS_VER.zip \
		&& unzip binutils-gdb-ce-$BINUTILS_VER.zip \
		&& rm -rf binutils-gdb-ce-$BINUTILS_VER.zip
RUN wget --progress=bar:force:noscroll -O w32api-wip.zip \
		https://github.com/MaxKellermann/w32api/archive/wip.zip \
		&& unzip w32api-wip.zip \
		&& rm -rf w32api-wip.zip \
		&& ln -s w32api-wip gcc-ce-$GCC_VER/winsup/w32api
RUN wget --progress=bar:force:noscroll -O mingwrt-wip.zip \
		https://github.com/MaxKellermann/mingwrt/archive/wip.zip \
		&& unzip mingwrt-wip.zip \
		&& rm -rf mingwrt-wip.zip \
		&& ln -s mingwrt-wip gcc-ce-$GCC_VER/winsup/mingw
# Downloading GCC dependencies manually because the contrib script for
# retrieving dependencies *still* uses FTP
ARG GMP_VER=6.1.0
RUN mkdir gcc-ce-$GCC_VER/gmp && \
	wget --progress=bar:force:noscroll -O - \
		https://ftp.gnu.org/gnu/gmp/gmp-$GMP_VER.tar.xz \
		| tar --strip-components=1 -C gcc-ce-$GCC_VER/gmp -xJf -
ARG MPFR_VER=3.1.4
RUN mkdir gcc-ce-$GCC_VER/mpfr && \
	wget --progress=bar:force:noscroll -O - \
		https://ftp.gnu.org/gnu/mpfr/mpfr-$MPFR_VER.tar.gz \
		| tar --strip-components=1 -C gcc-ce-$GCC_VER/mpfr -zxf -
ARG MPC_VER=1.0.3
RUN mkdir gcc-ce-$GCC_VER/mpc && \
	wget --progress=bar:force:noscroll -O - \
		https://ftp.gnu.org/gnu/mpc/mpc-$MPC_VER.tar.gz \
		| tar --strip-components=1 -C gcc-ce-$GCC_VER/mpc -zxf -
ARG ISL_VER=0.16.1
RUN mkdir gcc-ce-$GCC_VER/isl && \
	wget --progress=bar:force:noscroll -O - \
		https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.16.1.tar.bz2 \
		| tar --strip-components=1 -C gcc-ce-$GCC_VER/mpc -xjf -

ENV PATH=$PATH:/opt/mingw32ce/bin
ENV PKG_CONFIG_LIBDIR=/opt/mingw32ce/arm-mingw32ce/lib/pkgconfig

WORKDIR /tmp/compile/build
RUN ../binutils-gdb-ce-$BINUTILS_VER/configure \
		--prefix=/opt/mingw32ce \
		--build=$(dpkg-architecture -qDEB_BUILD_GNU_TYPE) \
		--host=$(dpkg-architecture -qDEB_HOST_GNU_TYPE) \
		--target=arm-mingw32ce \
		--disable-nls \
		--disable-werror && \
	make -j$(nproc) && \
	make -j$(nproc) install && \
	rm -r ../build

WORKDIR /tmp/compile/build
COPY ${WORKER_NAME}/libgcc.diff ./
RUN patch -p1 -i $PWD/libgcc.diff -d ../gcc-ce-$GCC_VER && \
	../gcc-ce-$GCC_VER/configure \
		--with-gcc \
		--with-gnu-ld \
		--with-gnu-as \
		--prefix=/opt/mingw32ce \
		--build=$(dpkg-architecture -qDEB_BUILD_GNU_TYPE) \
		--host=$(dpkg-architecture -qDEB_HOST_GNU_TYPE) \
		--target=arm-mingw32ce \
		--disable-threads \
		--disable-nls \
		--enable-languages=c \
		--disable-win32-registry \
		--disable-multilib \
		--disable-shared \
		--disable-interwork \
		--without-newlib \
		--enable-checking \
		--with-headers=$PWD/../w32api-wip/include && \
	make -j$(nproc) all-gcc && \
	make -j$(nproc) install-gcc && \
	make -j$(nproc) all-target-libgcc && \
	make -j$(nproc) install-target-libgcc && \
	rm -r ../build

WORKDIR /tmp/compile/build
COPY ${WORKER_NAME}/mingwrt.diff ./
RUN patch -p1 -i $PWD/mingwrt.diff -d ../mingwrt-wip && \
	../mingwrt-wip/configure \
		--prefix=/opt/mingw32ce \
		--build=$(dpkg-architecture -qDEB_BUILD_GNU_TYPE) \
		--host=arm-mingw32ce \
		--target=arm-mingw32ce \
		CFLAGS=-I$PWD/../w32api-wip/include && \
	make -j$(nproc) && \
	make -j$(nproc) install && \
	rm -r ../build

WORKDIR /tmp/compile/build
RUN ../w32api-wip/configure \
		--prefix=/opt/mingw32ce \
		--host=arm-mingw32ce \
		CFLAGS=-I$PWD/../mingwrt-wip/include && \
	make -j$(nproc) && \
	make -j$(nproc) install && \
	rm -r ../build

WORKDIR /tmp/compile/build
RUN ../gcc-ce-$GCC_VER/configure \
		--with-gcc \
		--with-gnu-ld \
		--with-gnu-as \
		--prefix=/opt/mingw32ce \
		--build=$(dpkg-architecture -qDEB_BUILD_GNU_TYPE) \
		--host=$(dpkg-architecture -qDEB_HOST_GNU_TYPE) \
		--target=arm-mingw32ce \
		--enable-threads=win32 \
		--disable-nls \
		--enable-languages=c,c++ \
		--disable-win32-registry \
		--disable-multilib \
		--disable-interwork \
		--without-newlib \
		--enable-checking \
		--with-headers \
		--disable-__cxa_atexit && \
	make -j$(nproc) && \
	make -j$(nproc) install && \
	rm -r ../build

COPY common/compile-libraries.sh ${WORKER_NAME}/compile-libraries-wince.sh ./

RUN sed 's/^deb \(.*\)/deb-src \1/' /etc/apt/sources.list \
		> /etc/apt/sources.list.d/debsrc.list && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		dpkg-dev \
		pkg-config

COPY ${WORKER_NAME}/library-rules/libsdl1.2.sh library-rules/
COPY ${WORKER_NAME}/libsdl1.2.diff .
RUN ./compile-libraries-wince.sh libsdl1.2

COPY common/library-rules/zlib.sh library-rules/
RUN ./compile-libraries-wince.sh zlib

COPY common/library-rules/freetype.sh library-rules/
RUN ./compile-libraries-wince.sh freetype

COPY common/library-rules/faad2.sh library-rules/
RUN ./compile-libraries-wince.sh faad2

COPY common/library-rules/libmad.sh library-rules/
RUN ./compile-libraries-wince.sh libmad

COPY common/library-rules/libogg.sh library-rules/
RUN ./compile-libraries-wince.sh libogg

COPY ${WORKER_NAME}/library-rules/libvorbisidec.sh library-rules/
COPY ${WORKER_NAME}/libvorbisidec.diff .
RUN ./compile-libraries-wince.sh libvorbisidec

FROM ${DEFAULT_BASE_IMAGE}
USER root
COPY --from=compiler /opt/mingw32ce /opt/mingw32ce
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
		libisl15 \
		libmpc3 \
		pkg-config \
		&& \
	rm -rf /var/lib/apt/lists/*
ENV PATH=$PATH:/opt/mingw32ce/bin
ENV PKG_CONFIG_LIBDIR=/opt/mingw32ce/arm-mingw32ce/lib/pkgconfig
ENV CXXFLAGS="$CXXFLAGS -isystem /opt/mingw32ce/arm-mingw32ce/include/SDL"

USER buildbot
WORKDIR /buildbot
