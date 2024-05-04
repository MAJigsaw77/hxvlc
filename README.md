<img src="https://github.com/MAJigsaw77/hxvlc/raw/main/logo.png" align="center" />

# hxvlc

![](https://img.shields.io/github/repo-size/MAJigsaw77/hxvlc) ![](https://badgen.net/github/open-issues/MAJigsaw77/hxvlc) ![](https://badgen.net/badge/license/MIT/green)

A Haxe/[OpenFL](https://www.openfl.org) library for @:native video playback using [libVLC](https://www.videolan.org/vlc/libvlc.html).

## Supported Platforms

- **Windows** (x86_64 only)
- **MacOS** (x86_64 and arm64 only)
- **Linux**
- **Android** (arm64, armv7a, x86, and x86_64 only)
- **iOS** (arm64 and simulator only)

> [!CAUTION]
> These platforms need to be compiled using [Lime](https://lime.openfl.org) targeting `cpp` to work.

## Instructions

1. Install the library:
	- Via `Haxelib`:
	  ```bash
	  haxelib install hxvlc
	  ```
	- Via `Git` for the latest updates:
	  ```bash
	  haxelib git hxvlc https://github.com/MAJigsaw77/hxvlc.git
	  ```

2. Add this code in the **project.xml** file:
	```xml
	<section if="cpp">
		<haxelib name="hxvlc" if="desktop || mobile" />
	</section>
	```

3. **Linux users only**: Install `vlc` from your distro's package manager.
	- [Debian](https://debian.org) based distributions:
		```bash
		sudo apt-get install libvlc-dev libvlccore-dev vlc-bin vlc
		```
	- [Arch](https://archlinux.org) based distributions:
		```bash
		sudo pacman -S vlc
		```
	- [Gentoo](https://www.gentoo.org) based distributions:
		```bash
		sudo emerge media-video/vlc
		```

4. **iOS users only**: 
	- Download the [MobileVLCKit Framework](https://download.videolan.org/cocoapods/unstable/MobileVLCKit-3.6.0b10-615f96dc-4733d1cc.tar.xz) and extract it.
	- In your app's `.xcodeproj` file, click on the target named after your app.
	- Navigate to `Build Settings` and change `Debug Information Format` to `DWARF`.
	- Go to `Build Phases/Link Binary With Libraries`, click on the plus sign at the bottom, and select `Add Other/Add Files`.
	- Locate the path of the `MobileVLCKit.xcframework` where you extracted the framework and add it.

5. **Well done!**

## Usage Examples

Check out the [Samples Folder](samples/) for examples on how to use this library.

## Licensing

**hxvlc** is made available under the **MIT License**. Check [LICENSE](./LICENSE) for more information.

<hr>

<a href="https://www.videolan.org/vlc/libvlc.html">
	<img src="https://images.videolan.org/images/goodies/Cone-Video-small.png" align="right" />
</a>

**libVLC** is released under the **LGPLv2 (or later) License**.

For more information, visit [VideoLAN.org](https://videolan.org/legal.html).

</hr>
