FROM alpine:3.13.2

ARG version
ENV VERSION=${version} \
  \
  DEV_PKGS="autoconf automake curl gcc git gperf g++ libtool make nasm pkgconfig python3 ragel" \
  PREFIX=/tmp/output \
  PKG_CONFIG_PATH="/tmp/output/lib/pkgconfig"

RUN apk add --no-cache ${DEV_PKGS} &&\
  # freetype
  git clone --recurse-submodules https://gitlab.freedesktop.org/freetype/freetype.git /tmp/freetype -b VER-2-10-4 --depth 1 &&\
  cd /tmp/freetype &&\
  ./autogen.sh &&\
  ./configure --prefix="${PREFIX}" --disable-static --enable-shared &&\
  make -j$(nproc) install &&\
  # fribidi
  git clone https://github.com/fribidi/fribidi.git /tmp/fribidi -b v1.0.10 --depth 1 &&\
  cd /tmp/fribidi &&\
  ./autogen.sh --prefix="${PREFIX}" --disable-static --enable-shared &&\
  make install &&\
  # harfbuzz
  git clone https://github.com/harfbuzz/harfbuzz.git /tmp/harfbuzz -b 2.7.4 --depth 1 &&\
  cd /tmp/harfbuzz &&\
  ./autogen.sh --prefix="${PREFIX}" --disable-static --enable-shared &&\
  make -j$(nproc) install &&\
  # libxml2
  git clone https://gitlab.gnome.org/GNOME/libxml2.git /tmp/libxml2 -b v2.9.10 --depth 1 &&\
  cd /tmp/libxml2 &&\
  ./autogen.sh --prefix="${PREFIX}" --with-ftp=no --with-http=no --with-python=no &&\
  make -j$(nproc) install &&\
  # fontconfig
  mkdir -p /tmp/fontconfig &&\
  cd /tmp/fontconfig &&\
  curl -sL https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.93.tar.gz | tar -zx --strip-components=1 &&\
  ./configure --prefix="${PREFIX}" --disable-static --enable-shared --enable-libxml2 &&\
    # https://gitlab.freedesktop.org/fontconfig/fontconfig/-/issues/272
    for i in doc/*.fncs; do \
      touch -r $i ${i//.fncs/.sgml}; \
    done &&\
  make -j$(nproc) install &&\
  # libass
  git clone https://github.com/libass/libass.git /tmp/libass -b ${VERSION} --depth 1 &&\
  cd /tmp/libass &&\
  ./autogen.sh &&\
  ./configure --prefix="${PREFIX}" --disable-static --enable-shared &&\
  make -j$(nproc) install &&\
  rm -rf /tmp/freetype &&\
  rm -rf /tmp/fribidi &&\
  rm -rf /tmp/harfbuzz &&\
  rm -rf /tmp/libxml2 &&\
  rm -rf /tmp/fontconfig &&\
  rm -rf /tmp/libass &&\
  apk del ${DEV_PKGS} &&\
  cp -r ${PREFIX} /output/
