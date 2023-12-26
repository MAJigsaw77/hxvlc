![](https://github.com/MAJigsaw77/hxvlc/raw/main/logo.png)

# hxvlc

![](https://img.shields.io/github/repo-size/MAJigsaw77/hxvlc) ![](https://badgen.net/github/open-issues/MAJigsaw77/hxvlc) ![](https://badgen.net/badge/license/MIT/green)

A Haxe/[OpenFL](https://www.openfl.org) library for video playback using [LibVLC](https://www.videolan.org/vlc/libvlc.html).

## Supported platforms

* Windows **(x86_64 only)**.
* MacOS **(x86_64 and arm64 only)**.
* Linux.
* Android **(arm64, armv7a, x86 and x86_64 only)**.
* IOS **(arm64 only)**.

These platforms needs be to compiled to C++ using [Lime](https://lime.openfl.org) in order to work.

## Instructions

1. Install the library.

   * You can install it through `Haxelib`
        ```bash
        haxelib install hxvlc
        ```

   * Or through `Git`, if you want the latest updates
        ```bash
        haxelib git hxvlc https://github.com/MAJigsaw77/hxvlc.git
        ```

3. Add this code in the **project.xml** file.

    ```xml
    <section if="cpp">
    	<haxelib name="hxvlc" if="desktop || android" />
    </section>
    ```

5. ***Linux users only***, you need to install [`vlc`](https://www.videolan.org/vlc) from your distro's package manager.

    * [Debian](https://debian.org) based distributions:
        ```bash
        sudo apt-get install vlc
        ```

    * [Arch](https://archlinux.org) based distributions:
        ```bash
        sudo pacman -S vlc
        ```

    * [Gentoo](https://www.gentoo.org) based distributions:
        ```bash
        sudo emerge media-video/vlc
        ```

6. **Well done!**

## Usage Examples

Check out the [Samples Folder](samples/) for examples on how to use this library.

## Licensing

**hxvlc** is made available under the **MIT License**. Check [LICENSE](./LICENSE) for more information.

![](https://github.com/videolan/vlc/raw/master/share/icons/256x256/vlc-xmas.png)

**LibVLC** is the engine of **VLC** released under the **LGPL2.1 License**. Check [VideoLAN.org](https://videolan.org/legal.html) for more information.

## Credits

| Avatar | User | Involvement |
| ------ | ---- | ----------- |
| ![](https://avatars.githubusercontent.com/u/77043862?s=64) | [MAJigsaw77](https://github.com/MAJigsaw77) | Creator of **hxvlc**.
| ![](https://avatars.githubusercontent.com/u/1677550?s=64) | [datee](https://github.com/datee) | Creator of [HaxeVLC](https://github.com/datee/HaxeVLC) and [VLC.hx](https://github.com/LogicInteractive/VLC.hx).
| ![](https://avatars.githubusercontent.com/u/107599365?v=64) | [Jonnycat](https://github.com/JonnycatMeow) | lib Supporter.
