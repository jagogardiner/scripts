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
        yum install -y zstd
        wget -O proton_clang.tar.zst https://kdrag0n.dev/files/redirector/proton_clang-latest.tar.zst
        mkdir "${KERNELDIR}"/clang
        tar -I zstd -xvf proton_clang.tar.zst -C "${KERNELDIR}"/clang
        COMPILER_STRING='Proton Clang (latest)'
        COMPILER_TYPE='clang'
elif [[ "$*" =~ "gcc10"* ]]; then
        git clone https://github.com/RaphielGang/aarch64-raph-linux-android -b elf --depth=1 "${KERNELDIR}/gcc"
        git clone https://github.com/baalajimaestro/arm-maestro-linux-gnueabi/ -b 240719 --depth=1 "${KERNELDIR}/gcc32"
        COMPILER_STRING='GCC 10 (experimental)'
        COMPILER_TYPE='GCC10'
elif [[ "$*" =~ "gcc4.9"* ]]; then
        git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 "${KERNELDIR}/gcc"
        cd gcc || exit
        # Google is a hoe
        git reset --hard 75c0ace0eb9ba47c11df56971e7f63f2ebaa9fbd
        cd ..
        COMPILER_STRING='GCC 4.9 from Google'
        COMPILER_TYPE='GCC4.9'
else
        # Default to GCC from kdrag0n
        git clone https://github.com/baalajimaestro/aarch64-maestro-linux-android -b 20102019-9.2.1 --depth=1 "${KERNELDIR}/gcc"
        git clone https://github.com/baalajimaestro/arm-maestro-linux-gnueabi -b 20102019 --depth=1 "${KERNELDIR}/gcc32"
        COMPILER_STRING='GCC 9'
        COMPILER_TYPE='GCC9'
fi

export COMPILER_STRING COMPILER_TYPE KERNELDIR SCRIPTS OUTDIR

# Do some silly defconfig replacements
if [[ "${PARSE_BRANCH}" =~ "staging"* ]]; then
	# For staging branch
	KERNELTYPE=nightly
	KERNELNAME="Acrux-${KERNELRELEASE}-Nightly-${COMPILER_TYPE}-$(date +%Y%m%d-%H%M)"
	sed -i "51s/.*/CONFIG_LOCALVERSION=\"-${KERNELNAME}\"/g" arch/arm64/configs/acrux_defconfig
elif [[ "${PARSE_BRANCH}" =~ "pie"* ]]; then
	# For stable (pie) branch
	KERNELTYPE=stable
	KERNELNAME="Acrux-${KERNELRELEASE}-Release-${COMPILER_TYPE}-$(date +%Y%m%d-%H%M)"
        sed -i "51s/.*/CONFIG_LOCALVERSION=\"-${KERNELNAME}\"/g" arch/arm64/configs/acrux_defconfig
else
	# Dunno when this will happen but we will cover, just in case
	KERNELTYPE=${PARSE_BRANCH}
	KERNELNAME="Acrux-${KERNELRELEASE}-${COMPILER_TYPE}-$(date +%Y%m%d-%H%M)"
        sed -i "51s/.*/CONFIG_LOCALVERSION=\"-${KERNELNAME}\"/g" arch/arm64/configs/acrux_defconfig
fi

export KERNELTYPE KERNELNAME

# Might as well export our zip
TEMPZIPNAME="${KERNELNAME}-unsigned.zip"
ZIPNAME="${KERNELNAME}.zip"

# Some misc enviroment vars
DEVICE=Platina
CIPROVIDER=Drone

# Our TG channels
CI_CHANNEL="-1001420038245"
TG_GROUP="-1001435271206"

export DEVICE CIPROVIDER TEMPZIPNAME ZIPNAME CI_CHANNEL TG_GROUP

# Export Telegram.sh Location
TELEGRAM=${KERNELDIR}/telegram/telegram
# Make sure our fekking token is exported ig?
TELEGRAM_TOKEN=${BOT_API_TOKEN}
# Export AnyKernel Location
ANYKERNEL=$(pwd)/anykernel3

# Examine our compilation threads
# 2x of our available CPUs
# Kanged from @raphielscape <3
CPU="$(grep -c '^processor' /proc/cpuinfo)"
JOBS="$((CPU * 2))"

# Parse git things
PARSE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PARSE_ORIGIN="$(git config --get remote.origin.url)"
COMMIT_POINT="$(git log --pretty=format:'%h : %s' -1)"

export TELEGRAM TELEGRAM_TOKEN JOBS ANYKERNEL PARSE_BRANCH PARSE_ORIGIN COMMIT_POINT
