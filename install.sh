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

LIB_NOVA_URL="https://git.code.sf.net/p/libnova/libnova"
LIB_NOVA_DIR="libnova"

CFITSIO_URL="http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio-4.0.0.tar.gz"
CFITSIO_DIR="cfitsio-4.0.0"

INDI_LIB_URL="https://github.com/indilib/indi.git"
INDI_LIB_DIR="indi"

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
  pkg up && pkg in -y git \
	wget cmake make \
	autoconf automake \
	libtool binutils tar \
	libjpeg-turbo gsl \
	libusb fftw pkg-config \
	libandroid-wordexp \
	libconfuse
}

msg "Installing build essentials and INDILib dependencies"
# install_dep

if [ -d "$LIB_NOVA_DIR" ]; then
  msg "$LIB_NOVA_DIR already exist skipping cloning"
else
  msg "Cloning $LIB_NOVA_DIR"
  git clone --depth=1 $LIB_NOVA_URL $LIB_NOVA_DIR
fi

msg "Building $LIB_NOVA_DIR"
configure_and_build "$LIB_NOVA_DIR" "autoconf"

if [ -d "$CFITSIO_DIR" ]; then
  msg "$CFITSIO_DIR already exist skipping download"
else
  msg "Downloading $CFITSIO_DIR"
  wget $CFITSIO_URL -O cfitsio.tar.gz
  msg "Extracting $CFITSIO_DIR"
  mkdir -p "$CFITSIO_DIR"
  tar -xvf cfitsio.tar.gz
  rm cfitsio.tar.gz
fi

msg "Building $CFITSIO_DIR"
configure_and_build "$CFITSIO_DIR" "configure"

if [ -d "$INDI_LIB_DIR" ]; then
  msg "$INDI_LIB_DIR already exist skipping cloning"
else
  msg "Cloning $INDI_LIB_DIR"
  git clone --depth=1 $INDI_LIB_URL $INDI_LIB_DIR
  cd $INDI_LIB_DIR 
  git apply ../indi.patch
  cd ..
fi

configure_and_build "$INDI_LIB_DIR" "cmake"
