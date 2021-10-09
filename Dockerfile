FROM python:alpine

ENV SHELL /bin/sh

ENV CC /usr/bin/clang
ENV CXX /usr/bin/clang++
ENV LANG C.UTF-8

ENV PYTHONUNBUFFERED 1
ENV PIP_DISABLE_PIP_VERSION_CHECK 1
ENV PIP_NO_CACHE_DIR 0
ENV TESSDATA_PREFIX /usr/local/share/tessdata

WORKDIR /tmp

RUN \
# Update system
    apk update \
# Install libraries
    && apk add --no-cache openssl leptonica openjpeg tiff libpng zlib freetype libgcc libstdc++ \
# Install development tools
    && apk add --no-cache --virtual .dev-deps file linux-headers git \
       make automake autoconf libtool pkgconfig clang g++ \
       openssl-dev leptonica-dev openjpeg-dev tiff-dev libpng-dev zlib-dev freetype-dev \
# Install Tesseract from master
    && mkdir /usr/local/share/tessdata \
    && mkdir tesseract \
    && cd tesseract \
    && wget https://github.com/tesseract-ocr/tessdata_fast/raw/main/eng.traineddata -P "$TESSDATA_PREFIX" \
    && git clone --depth 1 https://github.com/tesseract-ocr/tesseract.git . \
    && ./autogen.sh \
    && ./configure \
    && make -j$(nproc) \
    && make install \
# Install Python dependencies
    && pip install -U --no-cache-dir pytesseract \
# Cleanup
    && apk del .dev-deps \
    && rm -f /usr/local/lib/*.a \
    && rm -rf /tmp/* /var/cache/apk/*
