# Homebrew formula for axel (long-URL build).
#
# Intended to live in a tap repository so users can:
#   brew install proximile/tap/axel
#
# To set up the tap, create a public repo named "homebrew-tap" under the
# proximile account and drop this file in as Formula/axel.rb. On each release,
# bump `url` to the new tag and update `sha256` to match the source tarball
# (run: brew fetch --build-from-source ./axel.rb, or shasum -a 256 the tarball).
class Axel < Formula
  desc "Lightweight command line download accelerator with long-URL support"
  homepage "https://github.com/proximile/axel"
  url "https://github.com/proximile/axel/archive/refs/tags/v2.18.0.tar.gz"
  sha256 "f57b843a9d1a5c51fd5c4bb03f1058d6d27fee96e50273d1a1c1869778f65d88"
  license "GPL-2.0-or-later"
  head "https://github.com/proximile/axel.git", branch: "master"

  depends_on "autoconf" => :build
  depends_on "autoconf-archive" => :build
  depends_on "automake" => :build
  depends_on "gettext" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "txt2man" => :build
  depends_on "openssl@3"

  def install
    # gettext keeps its m4 macros (AM_GNU_GETTEXT) under share/gettext/m4,
    # which is off aclocal's default search path; add it so autoreconf works.
    ENV.prepend_path "ACLOCAL_PATH", "#{Formula["gettext"].opt_share}/gettext/m4"
    system "autoreconf", "-fiv"
    system "./configure", "--disable-Werror", "--disable-nls",
           "SSL_PREFIX=#{Formula["openssl@3"].opt_prefix}",
           *std_configure_args
    system "make"
    bin.install "axel"
    man1.install "doc/axel.1"
  end

  test do
    assert_match "Axel", shell_output("#{bin}/axel --version")
  end
end
