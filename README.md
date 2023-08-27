# hxvlc

![](https://img.shields.io/github/repo-size/MAJigsaw77/hxvlc) ![](https://badgen.net/github/open-issues/MAJigsaw77/hxvlc) ![](https://badgen.net/badge/license/MIT/green)

A Haxe/[OpenFL](https://www.openfl.org) library for video playback using [LibVLC](https://www.videolan.org/vlc/libvlc.html).

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

    **(Optional) Defines**
    ```xml
    <!-- LibVLC Logging for hxvlc -->
    <haxedef name="HXVLC_LOGGING" if="debug" />
    ```

## Linux Libs Instructions

In order to build a application with the library on **Linux**, you **have to install** `libvlc` and `libvlccore` from your distro's package manager.

* Debian based distributions:
    ```bash
    sudo apt-get install libvlc-dev libvlccore-dev 
    ```

* Arch based distributions:
    ```bash
    sudo pacman -S vlc 
    ```

## Usage Examples

Check out the [Samples Folder](samples/) for examples on how to use this library.

## Licensing

**hxvlc** is made available under the **MIT License**. Check [LICENSE](./LICENSE) for more information.

![](https://raw.githubusercontent.com/videolan/vlc/master/share/icons/256x256/vlc.png)

[***LibVLC***](https://www.videolan.org/vlc/libvlc.html) is the engine of **VLC** released under the **LGPLv2 License** (or later). Check [VideoLAN.org](https://www.videolan.org/legal.html) for more information.

## Credits

| Avatar | UserName | Involvement |
| ------ | -------- | ----------- |
| ![](https://avatars.githubusercontent.com/u/77043862?s=64) | [MAJigsaw77](https://github.com/MAJigsaw77) | Creator of **hxvlc**.
| ![](https://avatars.githubusercontent.com/u/1677550?s=64) | [datee](https://github.com/datee) | Creator of [**HaxeVLC**](https://github.com/datee/HaxeVLC).
| ![](https://avatars.githubusercontent.com/u/107599365?v=64) | [Jonnycat](https://github.com/JonnycatMeow) | MacOS Support.
