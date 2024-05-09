<img src="https://github.com/MAJigsaw77/hxvlc/raw/main/logo.png" align="center" />

# hxvlc

![](https://img.shields.io/github/repo-size/MAJigsaw77/hxvlc) ![](https://badgen.net/github/open-issues/MAJigsaw77/hxvlc) ![](https://badgen.net/badge/license/MIT/green)

A Haxe/[OpenFL](https://www.openfl.org) library for @:native video playback using [libVLC](https://www.videolan.org/vlc/libvlc.html).

### Supported Platforms

- **Windows** (x86_64 only)
- **MacOS** (x86_64 and arm64 only)
- **Linux**
- **Android** (arm64, armv7a, x86, and x86_64 only)
- **iOS** (arm64 and simulator only)

> [!CAUTION]
> These platforms need to be compiled using [Lime](https://lime.openfl.org) targeting `cpp` to work.

### Instructions

1. Install the library:
   - Via `Haxelib`:
     ```bash
     haxelib install hxvlc
     ```
   - Via `Git` for the latest updates:
     ```bash
     haxelib git hxvlc https://github.com/MAJigsaw77/hxvlc.git
     ```

3. Add this code in the **project.xml** file:
   ```xml
   <section if="cpp">
   	<haxelib name="hxvlc" if="desktop || mobile" />
   </section>
   ```

### Dependencies

On ***Linux*** you need to install `vlc` from your distro's package manager.

* [Debian](https://debian.org) based distributions:
  ```bash
  sudo apt-get install libvlc-dev libvlccore-dev vlc-bin vlc
  ```
* [Arch](https://archlinux.org) based distributions:
  ```bash
  sudo pacman -S vlc
  ```
* [Gentoo](https://gentoo.org) based distributions:
  ```bash
  sudo emerge media-video/vlc
  ```

### Usage Examples

Check out the [Samples Folder](samples/) for examples on how to use this library.

### Licensing

**hxvlc** is made available under the **MIT License**. Check [LICENSE](./LICENSE) for more information.

###

<a href="https://www.videolan.org/vlc/libvlc.html">
	<img src="https://images.videolan.org/images/goodies/Cone-Video-small.png" align="right" />
</a>

**libVLC** is released under the **LGPLv2 (or later) License**.

For more information, visit [VideoLAN.org](https://videolan.org/legal.html).
