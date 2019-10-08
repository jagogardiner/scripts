#!/bin/bash
#
# Copyright (C) 2019 nysascape
#
# Licensed under the Raphielscape Public License, Version 1.c (the "License");
# you may not use this file except in compliance with the License.
#
# Probably the 3rd bad apple coming

# Export home as en environment-wide thingy
export HOME=${SEMAPHORE_PROJECT_DIR}/..
export SCRIPTS=${HOME}/scripts

# Pick your poison
if [[ "$*" =~ "clang"* ]]; then
        git clone https://github.com/RaphielGang/aarch64-linux-gnu-8.x.git --depth=1 "${HOME}/gcc"
        git clone https://github.com/baalajimaestro/arm-maestro-linux-gnueabi/ -b 240719 --depth=1 "${HOME}/gcc32"
        git clone https://github.com/RaphielGang/aosp-clang --depth=1 "${HOME}"/clang
        export COMPILER='AOSP Clang (latest)'
elif [[ "$*" =~ "gcc10"* ]]; then
        git clone https://github.com/RaphielGang/aarch64-raph-linux-android -b elf --depth=1 "${HOME}/gcc"
        git clone https://github.com/baalajimaestro/arm-maestro-linux-gnueabi/ -b 240719 --depth=1 "${HOME}/gcc32"
        export COMPILER='GCC 10 (experimental)'
elif [[ "$*" =~ "gcc4.9"* ]]; then
        git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 "${HOME}/gcc"
        cd gcc || exit
        # Google is a hoe
        git reset --hard 75c0ace0eb9ba47c11df56971e7f63f2ebaa9fbd
        cd ..
        export COMPILER='GCC 4.9 from Google'
else
        # Default to GCC from kdrag0n
        git clone https://github.com/kdrag0n/aarch64-elf-gcc -b 9.x --depth=1 "${HOME}/gcc"
        git clone https://github.com/kdrag0n/arm-eabi-gcc -b 9.x --depth=1 "${HOME}/gcc32"
        export COMPILER='GCC 9.x'
fi

export telegram=
