#! /bin/bash

set -e
IFS=$' \t\n' # workaround for conda 4.2.13+toolchain bug

# Adopt a Unix-friendly path if we're on Windows (see bld.bat).
[ -n "$PATH_OVERRIDE" ] && export PATH="$PATH_OVERRIDE"

# Fresh OS-guessing scripts from xorg-util-macros for win64
for f in config.guess config.sub ; do
    cp -p $PREFIX/share/util-macros/$f .
done

export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig
configure_args=(
    --prefix=$PREFIX
    --disable-dependency-tracking
    --disable-selective-werror
    --disable-silent-rules
)

./configure "${configure_args[@]}"
make -j$CPU_COUNT
make install
make check

rm -rf $PREFIX/share/man $PREFIX/share/doc/${PKG_NAME#xorg-}

xcb_libs="
xcb
xcb-composite
xcb-damage
xcb-dpms
xcb-dri2
xcb-dri3
xcb-glx
xcb-present
xcb-randr
xcb-record
xcb-res
xcb-screensaver
xcb-shape
xcb-shm
xcb-sync
xcb-xf86dri
xcb-xfixes
xcb-xinerama
xcb-xkb
xcb-xtest
xcb-xv
xcb-xvmc
"

# Prefer dynamic libraries to static, and dump libtool helper files
for lib_ident in $xcb_libs ; do
    rm -f $PREFIX/lib/lib${lib_ident}.la
    if [ -e $PREFIX/lib/lib${lib_ident}$SHLIB_EXT ] ; then
        rm -f $PREFIX/lib/lib${lib_ident}.a
    fi
done
