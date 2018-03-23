ARG DEFAULT_BASE_IMAGE
ARG DEFAULT_OS_IMAGE
FROM devkitpro/devkitarm:20180613 as devkitarm
FROM ${DEFAULT_OS_IMAGE} as libraries
USER root
ARG WORKER_NAME

COPY --from=devkitarm /opt/devkitpro /opt/devkitpro

ENV DEVKITPRO=/opt/devkitpro
ENV DEVKITARM=$DEVKITPRO/devkitARM
ENV PATH=$PATH:$DEVKITARM/bin

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
COPY common/compile-libraries.sh ${WORKER_NAME}/compile-libraries-ds.sh ./

# Library rules are copied separately along with their corresponding library
# so that changes or additions to individual library scripts don't invalidate
# every single library layer
COPY ${WORKER_NAME}/library-rules/libmad.sh library-rules/
RUN ./compile-libraries-ds.sh libmad

FROM ${DEFAULT_BASE_IMAGE}
USER root

COPY --from=devkitarm /opt/devkitpro/devkitARM /opt/devkitpro/devkitARM
COPY --from=devkitarm /opt/devkitpro/tools /opt/devkitpro/tools
COPY --from=devkitarm /opt/devkitpro/libnds /opt/devkitpro/libnds
COPY --from=libraries /opt/devkitpro/portlibs/armv5te /opt/devkitpro/portlibs/armv5te

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		libgmp10 \
		&& \
	rm -rf /var/lib/apt/lists/*

ENV DEVKITPRO=/opt/devkitpro
ENV DEVKITARM=$DEVKITPRO/devkitARM
ENV PATH=$PATH:$DEVKITARM/bin:$DEVKITARM/arm-none-eabi/bin:$DEVKITPRO/tools/bin

USER buildbot
WORKDIR /buildbot
