# coding: utf-8
class Harfbuzz < Formula
  desc "OpenType text shaping engine"
  homepage "https://wiki.freedesktop.org/www/Software/HarfBuzz/"
  url "https://www.freedesktop.org/software/harfbuzz/release/harfbuzz-1.3.4.tar.bz2"
  sha256 "718aa6fcadef1a6548315b8cfe42cc27e926256302c337f42df3a443843f6a2b"

  bottle do
    sha256 "56c20acb139ba77ca7406842ec014e221f0b3bee85c60e66c38289b0bac40cd5" => :sierra
    sha256 "d0f860f4345cc1415615f3805d1ed00d21494a90ae0bc3493fd6bcf0aea4a23d" => :el_capitan
    sha256 "b1b83fa250585d07c990e963c828a634e9ee2a09a5288f6479ffb9b1eade529b" => :yosemite
    sha256 "47bbd9a193d8a3c03a464fdf36dde54f7e501cf7ab628a12496f33a9fc241481" => :x86_64_linux
  end

  head do
    url "https://github.com/behdad/harfbuzz.git"

    depends_on "ragel" => :build
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option :universal
  option "with-cairo", "Build command-line utilities that depend on Cairo"

  depends_on "pkg-config" => :build
  depends_on "freetype" => :recommended
  depends_on "glib" => :recommended
  depends_on "gobject-introspection" => :recommended
  depends_on "icu4c" => :recommended
  depends_on "cairo" => :optional
  depends_on "graphite2" => :optional

  resource "ttf" do
    url "https://github.com/behdad/harfbuzz/raw/fc0daafab0336b847ac14682e581a8838f36a0bf/test/shaping/fonts/sha1sum/270b89df543a7e48e206a2d830c0e10e5265c630.ttf"
    sha256 "9535d35dab9e002963eef56757c46881f6b3d3b27db24eefcc80929781856c77"
  end

  def install
    ENV.universal_binary if build.universal?

    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --with-coretext=#{OS.mac? ? "yes" : "no"}
      --enable-static
    ]

    if build.with? "cairo"
      args << "--with-cairo=yes"
    else
      args << "--with-cairo=no"
    end

    if build.with? "freetype"
      args << "--with-freetype=yes"
    else
      args << "--with-freetype=no"
    end

    if build.with? "glib"
      args << "--with-glib=yes"
    else
      args << "--with-glib=no"
    end

    if build.with? "gobject-introspection"
      args << "--with-gobject=yes" << "--enable-introspection=yes"
    else
      args << "--with-gobject=no" << "--enable-introspection=no"
    end

    if build.with? "graphite2"
      args << "--with-graphite2=yes"
    else
      args << "--with-graphite2=no"
    end

    if build.with? "icu4c"
      args << "--with-icu=yes"
    else
      args << "--with-icu=no"
    end

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make", "install"
  end

  test do
    resource("ttf").stage do
      shape = `echo 'സ്റ്റ്' | #{bin}/hb-shape 270b89df543a7e48e206a2d830c0e10e5265c630.ttf`.chomp
      assert_equal "[glyph201=0+1183|U0D4D=0+0]", shape
    end
  end
end
