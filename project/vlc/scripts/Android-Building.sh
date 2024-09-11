#!/bin/bash

# Author: Lily Ross (mcagabe19)

# Supported architectures
valid_archs=("arm" "arm64" "x86" "x86_64")

# Check if no arguments are provided
if [ $# -eq 0 ]; then
  echo "No architecture defined. (Possible values are arm, arm64, x86, or x86_64)"
  exit 1
fi

# Check if provided architecture(s) are valid
for arch in "$@"; do
  if [[ ! " ${valid_archs[*]} " =~ " ${arch} " ]]; then
    echo "Invalid architecture: $arch (Possible values are arm, arm64, x86, or x86_64)"
    exit 1
  fi
done

# Proceed with setup only after all architectures are validated
git clone https://code.videolan.org/videolan/libvlcjni.git --depth=1 --recursive -b libvlcjni-3.x
sudo apt-get install -y gettext autopoint automake ant autopoint cmake build-essential libtool-bin lua5.2 liblua5.2-dev patch pkg-config protobuf-compiler ragel subversion unzip git flex python3 wget nasm meson ninja-build
cd libvlcjni
mkdir ../build
git apply ../patches/libvlcjni/*
buildsystem/get-vlc.sh

# Compile for each valid architecture passed
for arch in "$@"; do
  ANDROID_NDK=$ANDROID_NDK_HOME buildsystem/compile-libvlc.sh -a "$arch" --no-jni --release

  # Move and copy relevant files based on architecture
  case "$arch" in
    arm)
      mv libvlcjni/libvlc/jni/libs/*/libvlc.so ../build/libvlc-v7.so
      cp $ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/arm-linux-androideabi/libc++_shared.so ../build/libc++_shared-v7.so
      ;;
    arm64)
      mv libvlcjni/libvlc/jni/libs/*/libvlc.so ../build/libvlc-64.so
      cp $ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/aarch64-linux-android/libc++_shared.so ../build/libc++_shared-64.so
      ;;
    x86)
      mv libvlcjni/libvlc/jni/libs/*/libvlc.so ../build/libvlc-x86.so
      cp $ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/i686-linux-android/libc++_shared.so ../build/libc++_shared-x86.so
      ;;
    x86_64)
      mv libvlcjni/libvlc/jni/libs/*/libvlc.so ../build/libvlc-x86_64.so
      cp $ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/sysroot/usr/lib/x86_64-linux-android/libc++_shared.so ../build/libc++_shared-x86_64.so
      ;;
  esac
done
