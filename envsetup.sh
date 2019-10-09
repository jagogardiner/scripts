#!/usr/bin/env bash
#
# Copyright (C) 2019 nysascape
#
# Licensed under the Raphielscape Public License, Version 1.c (the "License");
# you may not use this file except in compliance with the License.
#
# Probably the 3rd bad apple coming
# Enviroment variables

# Export KERNELDIR as en environment-wide thingy
# We start in scripts, so like, don't clone things there
KERNELDIR="$(pwd)"
SCRIPTS=${KERNELDIR}/kernelscripts
OUTDIR=${KERNELDIR}/out

# Pick your poison
if [[ "$*" =~ "clang"* ]]; then
        git clone https://github.com/RaphielGang/aarch64-linux-gnu-8.x.git --depth=1 "${KERNELDIR}/gcc"
        git clone https://github.com/baalajimaestro/arm-maestro-linux-gnueabi/ -b 240719 --depth=1 "${KERNELDIR}/gcc32"
        git clone https://github.com/RaphielGang/aosp-clang --depth=1 "${KERNELDIR}"/clang
        export COMPILER_STRING='AOSP Clang (latest)'
	export COMPILER_TYPE='clang'
elif [[ "$*" =~ "gcc10"* ]]; then
        git clone https://github.com/RaphielGang/aarch64-raph-linux-android -b elf --depth=1 "${KERNELDIR}/gcc"
        git clone https://github.com/baalajimaestro/arm-maestro-linux-gnueabi/ -b 240719 --depth=1 "${KERNELDIR}/gcc32"
        export COMPILER_STRING='GCC 10 (experimental)'
	export COMPILER_TYPE='GCC10'
elif [[ "$*" =~ "gcc4.9"* ]]; then
        git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 "${KERNELDIR}/gcc"
        cd gcc || exit
        # Google is a hoe
        git reset --hard 75c0ace0eb9ba47c11df56971e7f63f2ebaa9fbd
        cd ..
        export COMPILER_STRING='GCC 4.9 from Google'
	export COMPILER_TYPE='GCC4.9'
else
        # Default to GCC from kdrag0n
        git clone https://github.com/kdrag0n/aarch64-elf-gcc -b 9.x --depth=1 "${KERNELDIR}/gcc"
        git clone https://github.com/kdrag0n/arm-eabi-gcc -b 9.x --depth=1 "${KERNELDIR}/gcc32"
        export COMPILER_STRING='GCC 9.x'
	export COMPILER_TYPE='GCC9.x'
fi
