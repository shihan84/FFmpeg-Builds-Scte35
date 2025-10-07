#!/bin/bash

SCRIPT_REPO="https://github.com/BtbN/gmplib.git"
SCRIPT_COMMIT="ece1292e8282ef2c9ca204d1b510ff2aca04a7a3"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    ./.bootstrap

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --enable-maintainer-mode
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    else
        echo "Unknown target"
        return -1
    fi

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install DESTDIR="$FFBUILD_DESTDIR"
}

ffbuild_configure() {
    echo --enable-gmp
}

ffbuild_unconfigure() {
    echo --disable-gmp
}
