ARG DEFAULT_BASE_IMAGE
ARG DEFAULT_OS_IMAGE
FROM ${DEFAULT_OS_IMAGE} as devkitpro
USER root

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
		wget \
		bzip2

RUN wget -O devkitARMupdate.pl 'https://sourceforge.net/projects/devkitpro/files/Automated Installer/devkitARMupdate.pl/download' && \
	chmod +x devkitARMupdate.pl && \
	./devkitARMupdate.pl /opt/devkitpro
RUN wget -O devkitPPCupdate.pl 'https://sourceforge.net/projects/devkitpro/files/Automated Installer/devkitPPCupdate.pl/download' && \
	chmod +x devkitPPCupdate.pl && \
	./devkitPPCupdate.pl /opt/devkitpro

FROM ${DEFAULT_OS_IMAGE} as libraries
USER root
ARG WORKER_NAME

COPY --from=devkitpro /opt/devkitpro/devkitARM /opt/devkitpro/devkitARM
COPY --from=devkitpro /opt/devkitpro/devkitPPC /opt/devkitpro/devkitPPC
# COPY --from=devkitpro /opt/devkitpro/libctru /opt/devkitpro/libctru
COPY --from=devkitpro /opt/devkitpro/libnds /opt/devkitpro/libnds
COPY --from=devkitpro /opt/devkitpro/libogc /opt/devkitpro/libogc

ENV DEVKITPRO=/opt/devkitpro
ENV DEVKITPPC=$DEVKITPRO/devkitPPC
ENV DEVKITARM=$DEVKITPRO/devkitARM
ENV PATH=$PATH:$DEVKITPPC/bin:$DEVKITARM/bin

# dpkg-dev is required to retrieve sources from apt
# libgmp10 is required by the ARM compiler
RUN sed 's/^deb \(.*\)/deb-src \1/' /etc/apt/sources.list \
		> /etc/apt/sources.list.d/debsrc.list && \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		dpkg-dev \
		libgmp10

RUN mkdir -p /opt/devkitpro/portlibs/armv5te/bin

WORKDIR /tmp/compile
COPY common/compile-libraries.sh ${WORKER_NAME}/compile-libraries-wii.sh ${WORKER_NAME}/compile-libraries-ds.sh ./

# Library rules are copied separately along with their corresponding library
# so that changes or additions to individual library scripts don't invalidate
# every single library layer
COPY common/library-rules/zlib.sh library-rules/
RUN ./compile-libraries-wii.sh zlib

COPY common/library-rules/libpng1.6.sh library-rules/
RUN ./compile-libraries-wii.sh libpng1.6

COPY common/library-rules/freetype.sh library-rules/
RUN ./compile-libraries-wii.sh freetype

COPY common/library-rules/libjpeg-turbo.sh library-rules/
RUN ./compile-libraries-wii.sh libjpeg-turbo

COPY common/library-rules/faad2.sh library-rules/
RUN ./compile-libraries-wii.sh faad2

COPY ${WORKER_NAME}/library-rules/libmad.sh library-rules/
RUN ./compile-libraries-wii.sh libmad
RUN ./compile-libraries-ds.sh libmad

RUN ./compile-libraries-wii.sh libogg

COPY common/library-rules/libtheora.sh library-rules/
RUN ./compile-libraries-wii.sh libtheora

COPY common/library-rules/libvorbisidec.sh library-rules/
RUN ./compile-libraries-wii.sh libvorbisidec

COPY common/library-rules/mpeg2dec.sh library-rules/
RUN ./compile-libraries-wii.sh mpeg2dec

COPY ${WORKER_NAME}/library-rules/libgxflux.sh library-rules/
RUN ./compile-libraries-wii.sh libgxflux

# glibc       # configure fails, unsupported architecture
# flac        # build fails, utime/chown missing (from glibc)
# curl        # configure fails, gethostbyname missing (from glibc)
# glib2.0     # configure fails, iconv missing (from glibc)
# fluidsynth  # can't build, needs glib2.0
# libsdl2     # not used on this platform
# libsdl2-net # not used on this platform

FROM ${DEFAULT_BASE_IMAGE}
USER root

COPY --from=libraries /opt/devkitpro/devkitARM /opt/devkitpro/devkitARM
COPY --from=libraries /opt/devkitpro/devkitPPC /opt/devkitpro/devkitPPC
# COPY --from=libraries /opt/devkitpro/libctru /opt/devkitpro/libctru
COPY --from=libraries /opt/devkitpro/libnds /opt/devkitpro/libnds
COPY --from=libraries /opt/devkitpro/libogc /opt/devkitpro/libogc
COPY --from=libraries /opt/devkitpro/portlibs /opt/devkitpro/portlibs

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		libgmp10 \
		&& \
	rm -rf /var/lib/apt/lists/*

ENV DEVKITPRO=/opt/devkitpro
ENV DEVKITPPC=$DEVKITPRO/devkitPPC
ENV DEVKITARM=$DEVKITPRO/devkitARM
ENV PATH=$PATH:$DEVKITPPC/bin:$DEVKITPPC/powerpc-eabi/bin:$DEVKITARM/bin:$DEVKITARM/arm-none-eabi/bin

USER buildbot
WORKDIR /buildbot
