![](https://github.com/MAJigsaw77/hxvlc/blob/main/logo.png)

# hxvlc

![](https://img.shields.io/github/repo-size/MAJigsaw77/hxvlc) ![](https://badgen.net/github/open-issues/MAJigsaw77/hxvlc) ![](https://badgen.net/badge/license/MIT/green)

A Haxe/[OpenFL](https://www.openfl.org) library for video playback using [LibVLC](https://www.videolan.org/vlc/libvlc.html).

## Supported platforms

- [x] Windows **(x86_64 only)**.
- [x] MacOS **(x86_64 and arm64 only)**.
- [x] Linux **(x86_64 only)**.
- [x] Android **(arm64, armv7a, x86 and x86_64 only)**.

These platforms needs be to compiled to C++ using [Lime](https://lime.openfl.org) in order to work.

## Instructions

1. Install the latest stable version of `hxvlc` by running the following haxelib command.
    ```bash
    haxelib git hxvlc https://github.com/MAJigsaw77/hxvlc.git
    ```
2. Add this code in the **project.xml** file.
    ```xml
    <section if="cpp">
    	<haxelib name="hxvlc" if="desktop || android" />
    </section>
    ```

    **Optional** Defines.
    ```xml
    <haxedef name="HXVLC_LOGGING" if="debug" />
    ```
3. **Well done!**

## Linux Libs Instructions

In order to build a application with the library on **Linux**, you **have to install** `libvlc` and `libvlccore` from your distro's package manager.

* [Debian](https://debian.org) based distributions:
    ```bash
    sudo apt-get install libvlc-dev libvlccore-dev 
    ```

* [Arch](https://archlinux.org) based distributions:
    ```bash
    sudo pacman -S vlc 
    ```

## Usage Examples

Check out the [Samples Folder](samples/) for examples on how to use this library.

## Licensing

**hxvlc** is made available under the **MIT License**. Check [LICENSE](./LICENSE) for more information.

![](https://raw.githubusercontent.com/videolan/vlc/master/share/icons/256x256/vlc-xmas.png)

[**LibVLC**](https://www.videolan.org/vlc/libvlc.html) is the engine of **VLC** released under the **LGPLv2 License** (or later). Check [VideoLAN.org](https://www.videolan.org/legal.html) for more information.

## Credits

| Avatar | User | Involvement |
| ------ | ---- | ----------- |
| ![](https://avatars.githubusercontent.com/u/77043862?s=64) | [MAJigsaw77](https://github.com/MAJigsaw77) | Creator of **hxvlc**.
| ![](https://avatars.githubusercontent.com/u/1677550?s=64) | [datee](https://github.com/datee) | Creator of [HaxeVLC](https://github.com/datee/HaxeVLC) and [VLC.hx](https://github.com/LogicInteractive/VLC.hx).
| ![](https://avatars.githubusercontent.com/u/107599365?v=64) | [Jonnycat](https://github.com/JonnycatMeow) | MacOS Support.
