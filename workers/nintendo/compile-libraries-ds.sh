#!/usr/bin/env bash

nds_cflags="-march=armv5te -mtune=arm946e-s -mthumb-interwork -I$DEVKITPRO/portlibs/armv5te/include"
nds_ldflags="-march=armv5te -mtune=arm946e-s -mthumb-interwork -L$DEVKITPRO/portlibs/armv5te/lib"
CPPFLAGS=$nds_cflags LDFLAGS=$nds_ldflags ./compile-libraries.sh arm-none-eabi /opt/devkitpro/portlibs/armv5te $@
