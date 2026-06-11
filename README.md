# AXEL - Lightweight CLI download accelerator

## About

Axel tries to accelerate the download process by using multiple
connections per file, and can also balance the load between
different servers.

Axel tries to be as light as possible, so it might be useful on
byte-critical systems.

Axel supports HTTP, HTTPS, FTP and FTPS protocols.

Thanks to the original developer of Axel, Wilmer van der Gaast, and everyone
else who has contributed to it over the years.

## Usage

For usage information, see the manual page:

    man axel

## How to help
If you can code and are interested in improving Axel, please read the
[CONTRIBUTING.md](CONTRIBUTING.md) file; if you're looking for ideas check our
[open tickets](https://github.com/axel-download-accelerator/axel/issues/).

Additionally, there is a
[google group](https://groups.google.com/forum/#!forum/axel-accelerator-dev) to
discuss and to coordinate development. You can also find other developers in the
`#axel` channel on [Freenode](https://freenode.net/).

The sustainability of the project mainly depends on developers dedicating time,
so if you want to contribute but can't code, there's also the option to fund
paid development time through:

- *Ismael Luceno*
  + [Github Sponsors](https://github.com/sponsors/ismaell)
  + [![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/ismaell)
  + [![Liberapay](https://liberapay.com/assets/widgets/donate.svg)](https://liberapay.com/ismael/donate)

## Install

Prebuilt binaries for every release are published on the
[releases page](https://github.com/proximile/axel/releases). The Linux builds
are fully static — a single file with no dependencies that runs on any
distribution and works as a drop-in replacement for the stock `axel`.

### Quick install (Linux & macOS)

    curl -fsSL https://raw.githubusercontent.com/proximile/axel/master/install.sh | sh

This detects your OS and CPU, downloads the matching binary, and installs it to
`/usr/local/bin` (or `~/.local/bin` if that isn't writable). Pin a version with
`AXEL_VERSION=v2.18.0` or change the location with `AXEL_INSTALL_DIR=...`.

### Debian / Ubuntu (.deb) and Fedora / RHEL (.rpm)

Download the package for your architecture from the releases page, then:

    sudo apt install ./axel_<version>_amd64.deb      # Debian/Ubuntu
    sudo dnf install ./axel-<version>.x86_64.rpm     # Fedora/RHEL

These replace the distribution's `axel` package.

### macOS (Homebrew)

    brew install proximile/tap/axel

### Manual / Raspberry Pi

Grab the right tarball from the releases page (including `linux-armv6` for the
Raspberry Pi Zero and Pi 1), extract it, and copy `axel` onto your `PATH`:

    tar -xzf axel-<version>-linux-aarch64.tar.gz
    sudo install -m 0755 axel-<version>-linux-aarch64/axel /usr/local/bin/axel

### Windows

Use [WSL](https://learn.microsoft.com/windows/wsl/) and follow the Linux
instructions above. A Cygwin-based `.zip` is also attached to each release for
native use; it bundles the runtime DLLs it needs.

### From your distribution

Your operating system may also ship its own packaged version of Axel. If that
package is outdated, please get in touch with the package maintainer or open a
support ticket with your distro.

## Building from source
WARNING: Building from the source code repository is recommended only when doing
development, otherwise only use release tarballs.

Axel uses GNU autotools for it's buildsystem; instructions are provided in the
[INSTALL](INSTALL) file. The basic actions for most users are:

    ./configure && make && make install

To build without SSL/TLS support, pass to `configure` the `--without-ssl` flag.

If you're working from the source code repository instead of a release tarball,
you need to generate the buildsystem first with:

    autoreconf -i

When working from a git repository the build system will detect that and will
add -Werror to the CFLAGS if supported; so if you're not doing development you
should probably consider passing `--disable-Werror` to `configure` in order to
prevent build failures due to mere warnings.

### Dependencies
* `gettext` (or `gettext-tiny`)
* `pkg-config`

Optional:

* `libssl` (OpenSSL, LibreSSL or compatible) -- for SSL/TLS support.

#### Extra dependencies for building from snapshots
* `autoconf-archive`
* `autoconf`
* `automake`
* `autopoint`
* `txt2man`

#### Packages on Debian-based systems
* `build-essential`
* `autoconf`
* `autoconf-archive`
* `automake`
* `autopoint`
* `gettext`
* `libssl-dev`
* `pkg-config`
* `txt2man`


#### Packages on Mac OS X (Homebrew)
* `autoconf-archive`
* `automake`
* `gettext`
* `openssl`

### Building on Mac OS X (Homebrew)

You'll need to provide some extra options to autotools so it can find gettext
and openssl.

	GETTEXT=/usr/local/opt/gettext
	OPENSSL=/usr/local/opt/openssl
	PATH="$GETTEXT/bin:$PATH"

	[ -x configure ] || autoreconf -fiv -I$GETTEXT/share/aclocal/

	CFLAGS="-I$GETTEXT/include -I$OPENSSL/include" \
	LDFLAGS=-L$GETTEXT/lib ./configure

You can just run `make` as usual after these steps.

## Related projects ##

* [aria2](https://github.com/aria2/aria2)
* [hget](https://github.com/huydx/hget)
* [lftp](https://github.com/lavv17/lftp)
* [nugget](https://github.com/maxogden/nugget)
* [pget](https://github.com/Code-Hex/pget)

## License ##

Axel is licensed under GPL-2+ with the OpenSSL exception.
