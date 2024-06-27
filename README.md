<img src="https://github.com/MAJigsaw77/hxvlc/raw/main/assets/logo.png" align="center" />

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

### Installation

To install **hxvlc**, follow these steps:

1. **Haxelib Installation**
   - Install the library using Haxelib:
     ```bash
     haxelib install hxvlc
     ```
2. **Git Installation (for latest updates)**
   - Alternatively, clone the repository using Git:
     ```bash
     haxelib git hxvlc https://github.com/MAJigsaw77/hxvlc.git
     ```
3. **Project Configuration**
   - Add the following code to your **project.xml** file:
     ```xml
     <section if="cpp">
     	<haxelib name="hxvlc" if="desktop || mobile" />
     </section>
     ```

### Dependencies

On ***Linux*** you need to install `vlc` from your distro's package manager.

* [Debian](https://debian.org) based distributions:
    ```bash
    sudo apt-get install vlc libvlc-dev libvlccore-dev vlc-bin
    ```
* [Arch](https://archlinux.org) based distributions:
    ```bash
    sudo pacman -S vlc
    ```
* [Fedora](https://getfedora.org) based distributions:
    ```bash
    sudo dnf install vlc
    ```
* [Red Hat Enterprise Linux (RHEL)](https://www.redhat.com):
    ```bash
    sudo dnf install epel-release
    sudo dnf install vlc
    ```
* [openSUSE](https://www.opensuse.org) based distributions:
    ```bash
    sudo zypper install vlc
    ```
* [Gentoo](https://gentoo.org) based distributions:
    ```bash
    sudo emerge media-video/vlc
    ```
* [Slackware](https://www.slackware.com) based distributions:
    ```bash
    sudo slackpkg install vlc
    ```
* [Void Linux](https://voidlinux.org):
    ```bash
    sudo xbps-install -S vlc
    ```
* [NixOS](https://nixos.org):
    ```bash
    nix-env -iA nixpkgs.vlc
    ```

### Getting Started

- Explore the [Samples Folder](samples/) for examples of using this library with OpenFL and Flixel.

- Visit the [API Documentation](https://majigsaw77.github.io/hxvlc) for detailed information on available functionalities.

### Licensing

**hxvlc** is made available under the **MIT License**. Check [LICENSE](./LICENSE) for more information.

<a href="https://www.videolan.org/vlc/libvlc.html">
    <img src="https://images.videolan.org/images/goodies/Cone-Video-small.png" align="right" />
</a>

**libVLC** is released under the **LGPLv2 (or later) License**.

For more information, visit [VideoLAN.org](https://videolan.org/legal.html).
