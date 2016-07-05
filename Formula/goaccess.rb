class Goaccess < Formula
  desc "Log analyzer and interactive viewer for the Apache Webserver"
  homepage "https://goaccess.io/"
  url "http://tar.goaccess.io/goaccess-1.0.2.tar.gz"
  sha256 "58a83e201f29f0127b89032fbd40677558a643f6141b8c8413afd1e182f104f1"
  head "https://github.com/allinurl/goaccess.git"

  bottle do
    sha256 "79c0c79415f5e634afd15c5208bab66eed2e36ad507ad104c508c0885b69c01d" => :el_capitan
    sha256 "c5a6d0099a913c82217d8e7ea298e2c6b2a059ba7591a1e753ad4ffe9669c4b4" => :yosemite
    sha256 "fd070338e95c84373b3a70559f35a6afcf89f908af1816235d4b1f6b4ccb5f48" => :mavericks
  end

  option "with-geoip", "Enable IP location information using GeoIP"

  deprecated_option "enable-geoip" => "with-geoip"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "geoip" => :optional

  def install
    system "autoreconf", "-vfi"

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --enable-utf8
    ]

    args << "--enable-geoip" if build.with? "geoip"

    system "./configure", *args
    system "make", "install"
  end

  test do
    require "utils/json"

    (testpath/"access.log").write <<-EOS.undent
      127.0.0.1 - - [04/May/2015:15:48:17 +0200] "GET / HTTP/1.1" 200 612 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/42.0.2311.135 Safari/537.36"
    EOS

    output = shell_output("#{bin}/goaccess --time-format=%T --date-format=%d/%b/%Y --log-format='%h %^[%d:%t %^] \"%r\" %s %b \"%R\" \"%u\"' -f access.log -o json 2>/dev/null")

    assert_equal "Chrome", Utils::JSON.load(output)["browsers"]["data"][0]["data"]
  end
end
