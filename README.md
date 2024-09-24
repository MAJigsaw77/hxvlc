<img src="https://github.com/MAJigsaw77/hxvlc/raw/main/assets/logo.png" align="center" />

# hxvlc

![](https://img.shields.io/github/repo-size/MAJigsaw77/hxvlc) ![](https://badgen.net/github/open-issues/MAJigsaw77/hxvlc) ![](https://badgen.net/badge/license/MIT/green)

A Haxe/[OpenFL](https://www.openfl.org) library for @:native video playback using [libVLC](https://www.videolan.org/vlc/libvlc.html).

### Supported Platforms

**Hashlink or Neko are not supported**

- **Windows** (x86_64 only)
- **MacOS** (x86_64 and arm64 only)
- **Linux**
- **Android** (arm64, armv7a, x86, and x86_64 only)
- **iOS** (arm64 and simulator only)

### Installation

To install **hxvlc**, follow these steps:

1. **Haxelib Installation**
   ```bash
   haxelib install hxvlc
   ```
2. **Haxelib Git Installation (for latest updates)**
   ```bash
   haxelib git hxvlc https://github.com/MAJigsaw77/hxvlc.git
   ```
3. **Project Configuration** (Add the following code to your **project.xml** file)
   ```xml
   <section if="cpp">
   <haxelib name="hxvlc" if="desktop || mobile" />
   </section>
   ```

### Dependencies

On ***Linux*** you need to install `vlc` from your distro's package manager.

<details>
<summary>Commands list</summary>

#### Debian based distributions ([Debian](https://debian.org)):
```bash
sudo apt-get install vlc libvlc-dev libvlccore-dev vlc-bin
```

#### Arch based distributions ([Arch](https://archlinux.org)):
```bash
sudo pacman -S vlc
```

#### Fedora based distributions ([Fedora](https://getfedora.org)):
```bash
sudo dnf install vlc
```

#### Red Hat Enterprise Linux (RHEL):
```bash
sudo dnf install epel-release
sudo dnf install vlc
```

#### openSUSE based distributions ([openSUSE](https://www.opensuse.org)):
```bash
sudo zypper install vlc
```

#### Gentoo based distributions ([Gentoo](https://gentoo.org)):
```bash
sudo emerge media-video/vlc
```

#### Slackware based distributions ([Slackware](https://www.slackware.com)):
```bash
sudo slackpkg install vlc
```

#### Void Linux ([Void Linux](https://voidlinux.org)):
```bash
sudo xbps-install -S vlc
```

#### NixOS ([NixOS](https://nixos.org)):
```bash
nix-env -iA nixpkgs.vlc
```

</details>

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
