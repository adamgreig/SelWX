#!/bin/bash
# Written by Uwe Hermann <uwe@hermann-uwe.de>, released as public domain.
# Modified by Piotr Esden-Tempski <piotr@esden.net>, released as public domain.

TARGET=arm-none-eabi            # Or: TARGET=arm-elf
PREFIX=${HOME}/arm-none-eabi    # Install location of your final toolchain
PARALLEL=""                     # Or: PARALLEL="-j 5" for 4 CPUs
DARWIN_OPT_PATH=/opt/local      # Path in which MacPorts or Fink is installed

BINUTILS=binutils-2.19.1
GCC=gcc-4.4.2
NEWLIB=newlib-1.17.0
GDB=gdb-7.1
LIBCMSIS=v1.10-2
LIBSTM32=v3.0.0-1
LIBSTM32USB=v3.0.1-1
LIBOPENSTM32=master
LIBSTM32_EN=0
LIBOPENSTM32_EN=1

SUMMON_DIR=$(pwd)
SOURCES=${SUMMON_DIR}/sources

export PATH="${PREFIX}/bin:${PATH}"

GCCFLAGS=
GDBFLAGS=
BINUTILFLAGS=

case "$(uname)" in
    Linux)
    echo "Found Linux OS."
    ;;
    Darwin)
    echo "Found Darwin OS."
    GCCFLAGS="--with-gmp=${DARWIN_OPT_PATH} \
              --with-mpfr=${DARWIN_OPT_PATH} \
          -with-libiconv-prefix=${DARWIN_OPT_PATH}"
    ;;
    *)
    echo "Found unknown OS. Aborting!"
    exit 1
    ;;
esac

if [ ! -e ${SOURCES} ]; then
    mkdir ${SOURCES}
fi

cd ${SOURCES}

echo "Downloading binutils sources..."
wget -c http://ftp.gnu.org/gnu/binutils/${BINUTILS}.tar.bz2

echo "Downloading gcc sources..."
wget -c http://ftp.gnu.org/gnu/gcc/${GCC}/${GCC}.tar.bz2

echo "Downloading newlib sources..."
wget -c --no-passive-ftp ftp://sources.redhat.com/pub/newlib/${NEWLIB}.tar.gz

echo "Downloading gdb sources..."
wget -c http://ftp.gnu.org/gnu/gdb/${GDB}.tar.bz2

if [ ${LIBSTM32_EN} != 0 ]; then
if [ ! -e libcmsis-${LIBCMSIS}.tar.bz2 ]; then
    echo "Cloning libcmsis sources..."
    git clone git://git.open-bldc.org/libcmsis.git
        cd libcmsis
        git archive --format=tar --prefix=libcmsis-${LIBCMSIS}/ ${LIBCMSIS} | \
            bzip2 --stdout > ../libcmsis-${LIBCMSIS}.tar.bz2
        cd ..
        rm -rf libcmsis
fi

if [ ! -e libstm32-${LIBSTM32}.tar.bz2 ]; then
    echo "Cloning libstm32 sources..."
    git clone git://git.open-bldc.org/libstm32.git
        cd libstm32
        git archive --format=tar --prefix=libstm32-${LIBSTM32}/ ${LIBSTM32} | \
            bzip2 --stdout > ../libstm32-${LIBSTM32}.tar.bz2
        cd ..
        rm -rf libstm32
fi

if [ ! -e libstm32usb-${LIBSTM32USB}.tar.bz2 ]; then
    echo "Cloning libstm32usb sources..."
    git clone git://git.open-bldc.org/libstm32usb.git
        cd libstm32usb
        git archive --format=tar --prefix=libstm32usb-${LIBSTM32USB}/ ${LIBSTM32USB} | \
            bzip2 --stdout > ../libstm32usb-${LIBSTM32USB}.tar.bz2
        cd ..
        rm -rf libstm32usb
fi
fi

if [ ${LIBOPENSTM32_EN} != 0 ]; then
if [ ! -e libopenstm32-${LIBOPENSTM32}.tar.bz2 ]; then
    echo "Cloning libopenstm32 sources..."
    git clone git://libopenstm32.git.sourceforge.net/gitroot/libopenstm32/libopenstm32
        cd libopenstm32
        git archive --format=tar --prefix=libopenstm32-${LIBOPENSTM32}/ ${LIBOPENSTM32} | \
            bzip2 --stdout > ../libopenstm32-${LIBOPENSTM32}.tar.bz2
        cd ..
        rm -rf libopenstm32
fi
fi

cd ${SUMMON_DIR}

if [ ! -e build ]; then
    mkdir build
fi

if [ ! -e .${BINUTILS}.build ]; then
    echo "******************************************************************"
    echo "* Unpacking ${BINUTILS}"
    echo "******************************************************************"
    tar xfvj ${SOURCES}/${BINUTILS}.tar.bz2
    cd build
    echo "******************************************************************"
    echo "* Configuring ${BINUTILS}"
    echo "******************************************************************"
    ../${BINUTILS}/configure --target=${TARGET} \
                           --prefix=${PREFIX} \
                           --enable-interwork \
                           --enable-multilib \
                           --with-gnu-as \
                           --with-gnu-ld \
                           --disable-nls \
                           --disable-werror \
               ${BINUTILFLAGS} || exit
    echo "******************************************************************"
    echo "* Building ${BINUTILS}"
    echo "******************************************************************"
    make ${PARALLEL} || exit
    echo "******************************************************************"
    echo "* Installing ${BINUTILS}"
    echo "******************************************************************"
    make install || exit
    cd ..
    echo "******************************************************************"
    echo "* Cleaning up ${BINUTILS}"
    echo "******************************************************************"
    touch .${BINUTILS}.build
    rm -rf build/* ${BINUTILS}
fi

if [ ! -e .${GCC}-boot.build ]; then
    echo "******************************************************************"
    echo "* Unpacking ${GCC}-boot"
    echo "******************************************************************"
    tar xfvj ${SOURCES}/${GCC}.tar.bz2
    cd build
    echo "******************************************************************"
    echo "* Configuring ${GCC}-boot"
    echo "******************************************************************"
    ../${GCC}/configure --target=${TARGET} \
                      --prefix=${PREFIX} \
                      --enable-interwork \
                      --enable-multilib \
                      --enable-languages="c" \
                      --with-newlib \
                      --without-headers \
                      --disable-shared \
                      --with-gnu-as \
                      --with-gnu-ld \
                      --disable-nls \
                      --disable-werror \
              ${GCCFLAGS} || exit
    echo "******************************************************************"
    echo "* Building ${GCC}-boot"
    echo "******************************************************************"
    make ${PARALLEL} all-gcc || exit
    echo "******************************************************************"
    echo "* Installing ${GCC}-boot"
    echo "******************************************************************"
    make install-gcc || exit
    cd ..
    echo "******************************************************************"
    echo "* Cleaning up ${GCC}-boot"
    echo "******************************************************************"
    touch .${GCC}-boot.build
    rm -rf build/* ${GCC}
fi

if [ ! -e .${NEWLIB}.build ]; then
    echo "******************************************************************"
    echo "* Unpacking ${NEWLIB}"
    echo "******************************************************************"
    tar xfvz ${SOURCES}/${NEWLIB}.tar.gz
    cd build
    echo "******************************************************************"
    echo "* Configuring ${NEWLIB}"
    echo "******************************************************************"
    ../${NEWLIB}/configure --target=${TARGET} \
                         --prefix=${PREFIX} \
                         --enable-interwork \
                         --enable-multilib \
                         --with-gnu-as \
                         --with-gnu-ld \
                         --disable-nls \
                         --disable-werror \
                         --disable-newlib-supplied-syscalls || exit
    echo "******************************************************************"
    echo "* Building ${NEWLIB}"
    echo "******************************************************************"
    make ${PARALLEL} || exit
    echo "******************************************************************"
    echo "* Installing ${NEWLIB}"
    echo "******************************************************************"
    make install || exit
    cd ..
    echo "******************************************************************"
    echo "* Cleaning up ${NEWLIB}"
    echo "******************************************************************"
    touch .${NEWLIB}.build
    rm -rf build/* ${NEWLIB}
fi

# Yes, you need to build gcc again!
if [ ! -e .${GCC}.build ]; then
    echo "******************************************************************"
    echo "* Unpacking ${GCC}"
    echo "******************************************************************"
    tar xfvj ${SOURCES}/${GCC}.tar.bz2
    cd build
    echo "******************************************************************"
    echo "* Configuring ${GCC}"
    echo "******************************************************************"
    ../${GCC}/configure --target=${TARGET} \
                      --prefix=${PREFIX} \
                      --enable-interwork \
                      --enable-multilib \
                      --enable-languages="c,c++" \
                      --with-newlib \
                      --disable-shared \
                      --with-gnu-as \
                      --with-gnu-ld \
              --disable-nls \
                      --disable-werror \
             ${GCCFLAGS} || exit
    echo "******************************************************************"
    echo "* Building ${GCC}"
    echo "******************************************************************"
    make ${PARALLEL} || exit
    echo "******************************************************************"
    echo "* Installing ${GCC}"
    echo "******************************************************************"
    make install || exit
    cd ..
    echo "******************************************************************"
    echo "* Cleaning up ${GCC}"
    echo "******************************************************************"
    touch .${GCC}.build
    rm -rf build/* ${GCC}
fi

if [ ! -e .${GDB}.build ]; then
    echo "******************************************************************"
    echo "* Unpacking ${GDB}"
    echo "******************************************************************"
    tar xfvj ${SOURCES}/${GDB}.tar.bz2
    cd build
    echo "******************************************************************"
    echo "* Configuring ${GDB}"
    echo "******************************************************************"
    ../${GDB}/configure --target=${TARGET} \
                      --prefix=${PREFIX} \
                      --enable-interwork \
                      --enable-multilib \
                      --disable-werror \
              ${GDBFLAGS} || exit
    echo "******************************************************************"
    echo "* Building ${GDB}"
    echo "******************************************************************"
    make ${PARALLEL} || exit
    echo "******************************************************************"
    echo "* Installing ${GDB}"
    echo "******************************************************************"
    make install || exit
    cd ..
    echo "******************************************************************"
    echo "* Cleaning up ${GDB}"
    echo "******************************************************************"
    touch .${GDB}.build
    rm -rf build/* ${GDB}
fi

if [ ${LIBSTM32_EN} != 0 ]; then
if [ ! -e .libcmsis-${LIBCMSIS}.build ]; then
    echo "******************************************************************"
    echo "* Unpacking libcmsis-${LIBCMSIS}"
    echo "******************************************************************"
    tar xfvj ${SOURCES}/libcmsis-${LIBCMSIS}.tar.bz2
    cd libcmsis-${LIBCMSIS}
    echo "******************************************************************"
    echo "* Building libcmsis-${LIBCMSIS}"
    echo "******************************************************************"
    make arch_prefix=${TARGET} prefix=${PREFIX} || exit
    echo "******************************************************************"
    echo "* Installing libcmsis-${LIBCMSIS}"
    echo "******************************************************************"
    make arch_prefix=${TARGET} prefix=${PREFIX} install || exit
    cd ..
    echo "******************************************************************"
    echo "* Cleaning up libcmsis-${LIBCMSIS}"
    echo "******************************************************************"
    touch .libcmsis-${LIBCMSIS}.build
    rm -rf libcmsis-${LIBCMSIS}
fi

if [ ! -e .libstm32-${LIBSTM32}.build ]; then
    echo "******************************************************************"
    echo "* Unpacking libstm32-${LIBSTM32}"
    echo "******************************************************************"
    tar xfvj ${SOURCES}/libstm32-${LIBSTM32}.tar.bz2
    cd libstm32-${LIBSTM32}
    echo "******************************************************************"
    echo "* Building libstm32-${LIBSTM32}"
    echo "******************************************************************"
    make arch_prefix=${TARGET} prefix=${PREFIX} || exit
    echo "******************************************************************"
    echo "* Installing libstm32-${LIBSTM32}"
    echo "******************************************************************"
    make arch_prefix=${TARGET} prefix=${PREFIX} install || exit
    cd ..
    echo "******************************************************************"
    echo "* Cleaning up libstm32-${LIBSTM32}"
    echo "******************************************************************"
    touch .libstm32-${LIBSTM32}.build
    rm -rf libstm32-${LIBSTM32}
fi

if [ ! -e .libstm32usb-${LIBSTM32USB}.build ]; then
    echo "******************************************************************"
    echo "* Unpacking libstm32usb-${LIBSTM32USB}"
    echo "******************************************************************"
    tar xfvj ${SOURCES}/libstm32usb-${LIBSTM32USB}.tar.bz2
    cd libstm32usb-${LIBSTM32USB}
    echo "******************************************************************"
    echo "* Building libstm32usb-${LIBSTM32USB}"
    echo "******************************************************************"
    make arch_prefix=${TARGET} prefix=${PREFIX} || exit
    echo "******************************************************************"
    echo "* Installing libstm32usb-${LIBSTM32USB}"
    echo "******************************************************************"
    make arch_prefix=${TARGET} prefix=${PREFIX} install || exit
    cd ..
    echo "******************************************************************"
    echo "* Cleaning up libstm32usb-${LIBSTM32USB}"
    echo "******************************************************************"
    touch .libstm32usb-${LIBSTM32USB}.build
    rm -rf libstm32usb-${LIBSTM32USB}
fi
fi

if [ $LIBOPENSTM32_EN != 0 ]; then
    echo "******************************************************************"
    echo "* Unpacking libopenstm32-${LIBOPENSTM32}"
    echo "******************************************************************"
    tar xfvj ${SOURCES}/libopenstm32-${LIBOPENSTM32}.tar.bz2
    cd libopenstm32-${LIBOPENSTM32}
    echo "******************************************************************"
    echo "* Building libopenstm32-${LIBOPENSTM32}"
    echo "******************************************************************"
    make PREFIX=${TARGET} DESTDIR=${PREFIX} || exit
    echo "******************************************************************"
    echo "* Installing libopenstm32-${LIBOPENSTM32}"
    echo "******************************************************************"
    make PREFIX=${TARGET} DESTDIR=${PREFIX} install || exit
    cd ..
    echo "******************************************************************"
    echo "* Cleaning up libopenstm32-${LIBOPENSTM32}"
    echo "******************************************************************"
    touch .libopenstm32-${LIBOPENSTM32}.build
    rm -rf libopenstm32-${LIBOPENSTM32}
fi
