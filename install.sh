#!/usr/bin/bash -e

##
## DESCRIPTION: This file is used to build INDLib from source on
##              Termux Android
##
## AUTHOR: daoudeddy @Github
##
## DATE: Dec 30 2021
##
## USAGE: chmod +x install.sh && ./install.sh
##

export PREFIX="/data/data/com.termux/files/usr"

LIBNOVA_URL="https://git.code.sf.net/p/libnova/libnova"
LIBNOVA_DIR="libnova"

CFITSIO_URL="http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio-4.0.0.tar.gz"
CFITSIO_DIR="cfitsio-4.0.0"

LIBRAW_CMAKE_URL="https://github.com/LibRaw/LibRaw-cmake.git"
LIBRAW_CMAKE_DIR="libraw-cmake"

LIBRAW_URL="https://github.com/LibRaw/LibRaw.git"
LIBRAW_DIR="libraw"

LIBGPHOTO_URL="https://github.com/gphoto/libgphoto2/releases/download/v2.5.28/libgphoto2-2.5.28.tar.xz"
LIBGPHOTO_DIR="libgphoto"

LIBFTDI_URL="https://github.com/wjakob/libftdi.git"
LIBFTDI_DIR="libftdi"

INDILIB_URL="https://github.com/indilib/indi.git"
INDILIB_DIR="indi"

INDILIB_3P_URL="https://github.com/indilib/indi-3rdparty.git"
INDILIB_3P_DIR="indi-3rdparty"

G='\033[0;32m'
R='\033[0;31m'
NC='\033[0m'

function msg {
  echo -e "${G}"
  echo -e "********** $* **********"
  echo -e "${NC}"
}

function err {
  echo -e "${G}"
  echo -e "********** $* **********"
  echo -e "${NC}"
}

function configure_and_build {
  cd $1
  echo $PWD 
  if [ "$2" = "autogen" ]; then
    msg "Running autogen.sh"
    ./autogen.sh
    msg "Running configure"
    ./configure --prefix=$PREFIX
  elif [ "$2" = "autoconf" ]; then
    msg "Running autoreconf"
    autoreconf --install
    msg "Running configure"
    ./configure --prefix=$PREFIX
  elif [ "$2" = "cmake" ]; then
    msg "Running cmake"
    cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX .
  elif [ "$2" = "configure" ]; then
     msg "Running configure"
    ./configure --prefix=$PREFIX
  fi

  msg "Running make using $(nproc) cores"
  make -j$(nproc)
  msg "Running make install"
  make install
  cd ..
}

function install_dep {
  pkg up -y && pkg in -y git \
	wget cmake make \
	autoconf automake \
	libtool binutils tar \
	libjpeg-turbo gsl \
	libusb fftw pkg-config \
	libandroid-wordexp \
	libconfuse
}

msg "Installing build essentials and INDILib dependencies"
install_dep

if [ -d "$LIBNOVA_DIR" ]; then
  msg "$LIBNOVA_DIR already exist skipping clone"
else
  msg "Cloning $LIBNOVA_DIR"
  git clone --depth=1 $LIBNOVA_URL $LIBNOVA_DIR
  cd $LIBNOVA_DIR
  git apply ../libnova.patch
  cd ..
fi

msg "Building $LIBNOVA_DIR"
configure_and_build "$LIBNOVA_DIR" "autogen"

if [ -d "$CFITSIO_DIR" ]; then
  msg "$CFITSIO_DIR already exist skipping download"
else
  msg "Downloading $CFITSIO_DIR"
  wget $CFITSIO_URL -O cfitsio.tar.gz
  msg "Extracting $CFITSIO_DIR"
  mkdir -p "$CFITSIO_DIR"
  tar -xvf cfitsio.tar.gz -C $CFITSIO_DIR --strip-components 1
  rm cfitsio.tar.gz
fi

msg "Building $CFITSIO_DIR"
configure_and_build "$CFITSIO_DIR" "configure"

if [ -d "$LIBRAW_DIR" ]; then
  msg "$LIBRAW_DIR already exist skipping clone"
else
  msg "Cloning $LIBRAW_DIR"
  git clone --depth=1 $LIBRAW_CMAKE_URL $LIBRAW_CMAKE_DIR
  git clone --depth=1 $LIBRAW_URL $LIBRAW_DIR

  msg "Coppying $LIBRAW_CMAKE_DIR into $LIBRAW_DIR"
  cp -a $LIBRAW_CMAKE_DIR/. $LIBRAW_DIR
  rm -rf $LIBRAW_CMAKE_DIR
  cd $LIBRAW_DIR
  git apply ../libraw.patch
  cd ..
fi

msg "Building $LIBRAW_DIR"
configure_and_build "$LIBRAW_DIR" "cmake"

if [ -d "$LIBGPHOTO_DIR" ]; then
  msg "$LIBGPHOTO_DIR already exist skipping clone"
else
  msg "Cloning $LIBGPHOTO_DIR"
  wget $LIBGPHOTO_URL -O libgphoto.tar.xz
  mkdir -p $LIBGPHOTO_DIR
  tar -xvf libgphoto.tar.xz -C $LIBGPHOTO_DIR --strip-components 1
  rm libgphoto.tar.xz
fi

msg "Building $LIBGPHOTO_DIR"
configure_and_build "$LIBGPHOTO_DIR" "configure"

if [ -d "$LIBFTDI_DIR" ]; then
  msg "$LIBFTDI_DIR already exist skipping clone"
else
  msg "Cloning $LIBFTDI_DIR"
  git clone --depth=1 $LIBFTDI_URL $LIBFTDI_DIR
fi

msg "Building $LIBFTDI_DIR"
configure_and_build "$LIBFTDI_DIR" "cmake"

if [ -d "$INDILIB_DIR" ]; then
  msg "$INDILIB_DIR already exist skipping clone"
else
  msg "Cloning $INDILIB_DIR"
  git clone --depth=1 $INDILIB_URL $INDILIB_DIR
  cd $INDILIB_DIR 
  git apply ../indi.patch
  cd ..
fi

msg "Building $INDILIB_DIR"
configure_and_build "$INDILIB_DIR" "cmake"

if [ -d "$INDILIB_3P_DIR" ]; then
  msg "$INDILIB_3P_DIR already exist skipping clone"
else
  msg "Cloning $INDILIB_3P_DIR"
  git clone --depth=1 $INDILIB_3P_URL $INDILIB_3P_DIR
  cd $INDILIB_3P_DIR
  git apply ../indi-3rdparty.patch
  cd ..
fi

cd $INDILIB_3P_DIR
configure_and_build "libqsi" "cmake"
configure_and_build "libqhy" "cmake"
configure_and_build "libfishcamp" "cmake"
configure_and_build "libapogee" "cmake"
cd ..

msg "Building $INDILIB_3P_DIR"
configure_and_build "$INDILIB_3P_DIR" "cmake"
