#!/bin/bash

# -------------------------------------
# Author: Mihai Alexandru (M.A. Jigsaw)
# -------------------------------------

# Check if the first argument is valid.
if [ -z "$1" ]; then
	echo "Error: No platform specified. Usage: $0 <platform>"
	exit 1
fi

# Detect OS
if [[ "$(uname -s)" != "Darwin" ]]; then
	echo "Unsupported OS: $(uname -s)"
	exit 1
fi

# Exit on any error.
set -e

# Per platform config
if [ "$2" = "simulator"]
    PLATFORM="iphonesimulator"
elif [ "$2" = "phone" ] ; then
	PLATFORM="iphoneos"
else
	echo "Error: Unknown platform '$1'. Supported platforms: simulator, ios."
	exit 1
fi

# First, get "vlckit" source.
git clone https://code.videolan.org/videolan/VLCKit.git --depth=1 --recursive -b 3.0

# Function to reoder Git patches.
reorder_patches()
{
	local dir="$1"

	shift

	local REMOVE_PATCHES=("$@")

	cd "$dir" || exit 1

	for patch in "${REMOVE_PATCHES[@]}"; do
		rm -f "$patch"
	done

	local i=1

	for patch in $(ls | sort); do
		local new_name=$(printf "%04d-%s" "$i" "$(echo "$patch" | cut -d- -f2-)")

		if [[ "$patch" != "$new_name" ]]; then
			mv "$patch" "$new_name"
		fi

		((i++))
	done
}

# Function to download "vlc" and apply patches.
download_vlc()
{
	TESTEDHASH="ac310b4b" # vlc hash that this version of VLCKit is build on

	if ! [ -e vlc ]; then
		git clone https://code.videolan.org/videolan/vlc.git --branch 3.0.x --single-branch vlc

		echo "Applying patches to vlc.git"

		cd vlc

		git checkout -B localBranch ${TESTEDHASH}
		git branch --set-upstream-to=3.0.x localBranch
		git am ../VLCKit/libvlc/patches/*.patch

		if [ $? -ne 0 ]; then
			git am --abort
			echo "Applying the patches failed, aborting git-am"
			exit 1
		fi

		cd ..
	else
		cd vlc

		git fetch --all
		git reset --hard ${TESTEDHASH}
		git am ${ROOT_DIR}/libvlc/patches/*.patch

		cd ..
	fi
}

# Function to compile "libvlc".
compile_vlc()
{
	ARCH="$1"
	SDK_PLATFORM="$2"
	SDK_VERSION=$(xcrun --sdk $SDK_PLATFORM --show-sdk-version)
	SDK="$2-$SDK_VERSION"

	cd vlc

	extras/package/apple/build.sh --arch=$ARCH --sdk=$SDK --disable-debug

	cp -r vlc-$SDK-$ARCH/include/* ../build/${ARCH}_$SDK_PLATFORM/include/

	strip -S libvlc-full-static.a

	cp libvlc-full-static.a ../build/lib/libvlc_${ARCH}_$SDK_PLATFORM.a

	cd ..
}

# Remove the following patches as they change the api which is not what we need.
reorder_patches "VLCKit/libvlc/patches" \
	"0004-http-add-vlc_http_cookies_clear.patch" \
    "0005-libvlc_media-add-cookie_jar-API.patch" \
    "0009-input-Extract-attachment-also-when-preparsing.patch" \
    "0011-libvlc-add-a-basic-API-to-change-freetype-s-color-bo.patch" \
    "0020-libvlc-media_player-Add-record-method.patch" \
    "0021-libvlc-events-Add-callbacks-for-record.patch" \
    "0027-lib-media_player-add-stop-set_media-async-support.patch" \
    "0031-lib-media_player-add-loudness-event.patch" \
    "0036-http-cookie-fix-double-free.patch"

# Get "vlc" source.
download_vlc

# Make the output directory
mkdir -p build/lib

# Compile and create the output directory
if [ "$PLATFORM" = "iphonesimulator" ]; then
	compile_vlc "x86_64" "iphonesimulator"
	compile_vlc "aarch64" "iphonesimulator"

	mkdir -p build/aarch64_iphonesimulator/include
	mkdir -p build/x86_64_iphonesimulator/include
else
	compile_vlc "aarch64" "iphoneos"

	mkdir -p build/aarch64_iphoneos/include
fi

# Merge libs together
if [ "$PLATFORM" = "iphonesimulator" ]; then
	lipo -create -output build/libvlc_sim.a build/libvlc_x86_64_iphonesimulator.a build/libvlc_aarch64_iphonesimulator.a
	rm build/libvlc_x86_64_iphonesimulator.a
	rm build/libvlc_aarch64_iphonesimulator.a
else
	mv build/libvlc_device.a build/libvlc_aarch64_iphoneos.a

# Finish
echo ""
echo "Build succeeded!"
