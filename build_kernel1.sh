#!/bin/bash

# Check if have toolchain/llvm folder

if [ ! -d "$(pwd)/gcc/" ]; then

   git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 gcc -b android-msm-sunfish-4.14-t-preview-2 --depth 1 >> /dev/null 2> /dev/null

fi

if [ ! -d "$(pwd)/clang/" ]; then

   git clone https://github.com/kdrag0n/proton-clang clang --depth 1 >> /dev/null 2> /dev/null

fi

# Export KBUILD flags

export KBUILD_BUILD_USER="Geekmaster21"

export KBUILD_BUILD_HOST="OVH"

# Export ARCH/SUBARCH flags

export ARCH="arm64"

export SUBARCH="arm"

# Export ANDROID VERSION

export PLATFORM_VERSION=13

export ANDROID_MAJOR_VERSION=T

# Export CCACHE

export CCACHE_EXEC="$(which ccache)"

export CCACHE="${CCACHE_EXEC}"

export CCACHE_COMPRESS="1"

export USE_CCACHE="1"

ccache -M 50G

# Export toolchain/clang/llvm flags

export CROSS_COMPILE="/home/ubuntu/Kernel/gcc/bin/aarch64-linux-android-"

export CLANG_TRIPLE="aarch64-linux-gnu-"
export CC="/home/ubuntu/Kernel/clang/bin/clang"
KERNEL_MAKE_ENV="DTC_EXT=/home/ubuntu/Kernel/tools/dtc" 
# Export if/else outdir var

export WITH_OUTDIR=true

# Clear the console

clear

# Remove out dir folder and clean the source

if [ "${WITH_OUTDIR}" == true ]; then

   if [ ! -d "$(pwd)/a71" ]; then

      mkdir a71

   fi

fi

# Build time

if [ "${WITH_OUTDIR}" == true ]; then

   if [ ! -d "$(pwd)/a71" ]; then

      mkdir a71

   fi

fi

if [ "${WITH_OUTDIR}" == true ]; then

   "${CCACHE}" make O=a71 $KERNEL_MAKE_ENV a71_defconfig

   "${CCACHE}" make -j$(nproc --all) $KERNEL_MAKE_ENV O=a71

   tools/mkdtimg create a71/arch/arm64/boot/dtbo.img --page_size=4096 $(find a71/arch -name "*.dtbo")

fi
