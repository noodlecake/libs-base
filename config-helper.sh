#!/bin/bash

export GNUSTEP_HOME=/Volumes/Noodlecake/newblitz/android-helpers/GNUStep/Debug/arm64-v8a/
export GNUSTEP_MAKEFILES=${GNUSTEP_HOME}/share/GNUStep/Makefiles


source ${GNUSTEP_MAKEFILES}/GNUstep.sh
export PATH=$PATH:${GNUSTEP_HOME}/bin

export NDK=/Users/spencer/Library/Android/sdk/ndk/23.1.7779620/

# Only choose one of these, depending on your build machine...
export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64
#export TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64

# Only choose one of these, depending on your device...
export TARGET=aarch64-linux-android
#export TARGET=armv7a-linux-androideabi
#export TARGET=i686-linux-android
#export TARGET=x86_64-linux-android

# Set this to your minSdkVersion.
export API=21

# Configure and build.
export AR=$TOOLCHAIN/bin/llvm-ar
export CC=$TOOLCHAIN/bin/$TARGET$API-clang
export AS=$CC
export CXX=$TOOLCHAIN/bin/$TARGET$API-clang++
export LD=$TOOLCHAIN/bin/ld
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip
./configure --host $TARGET --enable-nxconstantstring --enable-procfs --enable-procfs-psinfo
