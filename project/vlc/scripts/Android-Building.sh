#!/bin/bash

# -------------------------------------
# Author: Mihai Alexandru (M.A. Jigsaw)
# -------------------------------------

# Check if the first argument is valid.
if [ -z "$1" ]; then
	echo "Error: No architecture specified. Usage: $0 <architecture>"
	exit 1
fi

# Detect OS
if [[ "$(uname -s)" == "Darwin" ]]; then
	HOST_TAG="darwin-x86_64"
elif [[ "$(uname -s)" == "Linux" ]]; then
	HOST_TAG="linux-x86_64"
else
	echo "Unsupported OS: $(uname -s)"
	exit 1
fi

# Exit on any error.
set -e

# Per architecture config
if [ "$1" = "arm64" ]; then
	TARGET_TUPLE="aarch64-linux-android"
	SHORT_ARCH="arm64"
	JNI_DIR_NAME="arm64-v8a"
	NUMBER_ARCH="64"
elif [ "$1" = "armv7a" ]; then
	TARGET_TUPLE="arm-linux-androideabi"
	SHORT_ARCH="arm"
	JNI_DIR_NAME="armeabi-v7a"
	NUMBER_ARCH="v7"
elif [ "$1" = "x86" ]; then
	TARGET_TUPLE="i686-linux-android"
	SHORT_ARCH="x86"
	JNI_DIR_NAME="x86"
	NUMBER_ARCH="x86"
elif [ "$1" = "x86_64" ]; then
	TARGET_TUPLE="x86_64-linux-android"
	SHORT_ARCH="x86_64"
	JNI_DIR_NAME="x86_64"
	NUMBER_ARCH="x86_64"
else
	echo "Error: Unknown architecture '$1'. Supported architectures: arm64, armv7a, x86, x86_64."
	exit 1
fi

# First, get "libvlcjni" source.
git clone https://code.videolan.org/videolan/libvlcjni.git --depth=1 --recursive -b libvlcjni-3.x

# Enter "libvlcjni" source.
cd libvlcjni

# Get "vlc" source.
buildsystem/get-vlc.sh

# Make prebuilt contribs bars.
export VLC_CONTRIB_SHA=$(cd vlc && extras/ci/get-contrib-sha.sh android-$SHORT_ARCH)
export VLC_PREBUILT_CONTRIBS_URL=https://artifacts.videolan.org/vlc/android-$SHORT_ARCH/vlc-contrib-$TARGET_TUPLE-$VLC_CONTRIB_SHA.tar.bz2

# Compile "libvlc".
buildsystem/compile-libvlc.sh -a $SHORT_ARCH --no-jni --release --with-prebuilt-contribs

# Make the output directory
mkdir -p ../build/include
mkdir -p ../build/lib

# Copy files to the output directory
cp -r vlc/build-android-$TARGET_TUPLE/install/include/* ../build/include/
cp libvlc/jni/libs/$JNI_DIR_NAME/libvlc.so ../build/lib/libvlc-$NUMBER_ARCH.so
cp libvlc/jni/libs/$JNI_DIR_NAME/libc++_shared.so ../build/lib/libc++_shared-$NUMBER_ARCH.so

# Finish
echo ""
echo "Build succeeded!"
