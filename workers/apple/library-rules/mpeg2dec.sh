get_dependencies automake libtool
do_fetch

# mpeg2dec assumes that a powerpc host will have altivec, but this is not
# the case for Amiga nor Nintendo PowerPC CPUs, so just disable it always
sed -i 's/have_altivec=yes/have_altivec=no/' configure

do_configure

if [[ $host == arm-apple-darwin* ]]; then
	# the ARM assembler for iOS cannot process .internal directives, so undo the
	# patch that adds them or compilation will fail
	patch -R -p1 < debian/patches/60_arm-private-symbols.patch

	# Fix missing leading underscores in .global symbols in arm asm
	sed -i 's/MC_put_o_16_arm/_MC_put_o_16_arm/' libmpeg2/motion_comp_arm_s.S
	sed -i 's/MC_put_o_8_arm/_MC_put_o_8_arm/' libmpeg2/motion_comp_arm_s.S
	sed -i 's/MC_put_x_16_arm/_MC_put_x_16_arm/' libmpeg2/motion_comp_arm_s.S
	sed -i 's/MC_put_x_8_arm/_MC_put_x_8_arm/' libmpeg2/motion_comp_arm_s.S
fi

# libvo is not needed, and fails to cross-compile for at least Windows, so just
# don't bother to compile it
echo "all install clean:" > libvo/Makefile

# We only want the library, and the utilities fail to compile due to duplicate
# standard library function definitions
echo "all install clean:" > src/Makefile

do_make
