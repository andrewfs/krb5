#! /bin/bash

#
# Program : android-configure.sh
# Author  : Chris Conlon, wolfSSL (www.wolfssl.com)
#
# Date    : February 15, 2012
#
# Description: This script will configure the MIT Kerberos library
#              for cross-compilation by the Android NDK stand-
#              alone toolchain.
#
# Instructions:
#   1) Download, install, and set up the Android SDK and Android NDK 
#      standalone toolchain.
#           SDK:  http://developer.android.com/sdk/index.html
#           NDK:  http://developer.android.com/sdk/ndk/index.html
#   2) Place this script in the /src directory of the kerberos
#      source directory.
#   3) Run ./autoconf if needed
#   4) Run ./android-configure.sh
#   5) Exclude the following directories by removing or renaming them.
#      NOTE: This script does this automatically.
#           mv ./clients ./clients.exclude   [ kerberos clients ]
#           mv ./tests ./tests.exclude       [ kerberos tests ]
#           mv ./appl ./appl.exclude         [ kerberos applications ]
#           mv ./kadmin ./kadmin.exclude     [ kadmin ]
#   6) Run make
#   7) Install in desired location:
#           make DESTDIR=<staging/path/here> install
#   8) Copy built libraries from staging location to desired 
#      Android project.
#

## Add Android NDK Cross Compile toolchain to path
#export NDK_TC_ROOT=/home/afernandes/opt/ndk-standalone-v21-arm
export NDK_TC_ROOT=/home/afernandes/opt/ndk-standalone-v21-x86

export PATH=$NDK_TC_ROOT:$PATH

## Set up variables to point to Cross-Compile tools
export CCBIN="$NDK_TC_ROOT/bin"
#export CCTOOL="$CCBIN/arm-linux-androideabi-"
export CCTOOL="$CCBIN/i686-linux-android-"

## Export our ARM/Android NDK Cross-Compile tools
export CC="${CCTOOL}gcc"
export RANLIB="${CCTOOL}ranlib"
export AR="${CCTOOL}ar"

## Point these to your cross-compiled CyaSSL library location. CyaSSL can be
## built for Android using the cyassl-android-ndk package or by
## cross-compiling it for Android using wolfSSL's shell script (www.wolfssl.com)
## and the Android NDK Standalone toolchain.
export CYASSL_DIR="/home/afernandes/work/krb5/cyassl-out"
export CYASSL_LIB="$CYASSL_DIR/lib"
export CYASSL_INC="$CYASSL_DIR/include"
export LDFLAGS="-L$CYASSL_LIB -lcyassl -lm"
export CFLAGS="-I$CYASSL_INC -DANDROID"

## Configure the library
#arm
#ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes krb5_cv_attr_constructor_destructor=yes ac_cv_func_regcomp=yes ac_cv_printf_positional=no ./configure --target=arm-linux-androideabi --host=arm-linux-androideabi --enable-static --disable-shared --with-crypto-impl=cyassl --with-prng-alg=os --prefix="/home/afernandes/work/krb5/krb5-out"

#x86
ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes krb5_cv_attr_constructor_destructor=yes ac_cv_func_regcomp=yes ac_cv_printf_positional=no ./configure --target=i686-linux-android --host=i686-linux-android --enable-static --disable-shared --with-crypto-impl=cyassl --with-prng-alg=os --prefix="/home/afernandes/work/krb5/krb5-out"

## Adjust autoconf.h's KRB5_DNS_LOOKUP definition
sed -i.bak 's/#define KRB5_DNS_LOOKUP 1/#undef KRB5_DNS_LOOKUP/g' include/autoconf.h

##  Skip building the parts we don't need. After running ./configure, if a 
##  folder is renamed or deleted, it will be skipped during the build process.
##  THIS ONLY WORKS THE FIRST GO AROUND, YOU NEED TO MOVE THE FOLDERS BACK
##  TO THEIR ORIGINAL LOCATION IF YOU WANT TO RUN CONFIGURE AGAIN!!!
if [ -d "./appl" ]; then
    mv ./appl ./appl.exclude
    echo "Renamed ./appl to ./appl.exclude"
fi
if [ -d "./clients" ]; then
    mv ./clients ./clients.exclude
    echo "Renamed ./clients to ./clients.exclude"
fi
if [ -d "./tests" ]; then
    mv ./tests ./tests.exclude
    echo "Renamed ./tests to ./tests.exclude"
fi
if [ -d "./kadmin" ]; then
    mv ./kadmin ./kadmin.exclude
    echo "Renamed ./kadmin to ./kadmin.exclude"
fi

make clean
make
make install
