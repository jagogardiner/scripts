#!/usr/bin/env bash
#
# Copyright (C) 2019 nysascape
#
# Licensed under the Raphielscape Public License, Version 1.c (the "License");
# you may not use this file except in compliance with the License.
#
# Semaphore build script for Acrux

# Make sure our fekking token is exported ig?
export TELEGRAM_TOKEN=${BOT_API_TOKEN}

# Some misc enviroment vars
DEVICE=Platina
CIPROVIDER=Semaphore

# Clone our AnyKernel3 branch to KERNELDIR
git clone https://github.com/nysascape/Acrux-AK3 -b master anykernel3
export ANYKERNEL=$(pwd)/anykernel3

# Parse git things
PARSE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PARSE_ORIGIN="$(git config --get remote.origin.url)"
COMMIT_POINT="$(git log --pretty=format:'%h : %s' -1)"

# Do some silly defconfig replacements
if [[ "${PARSE_BRANCH}" =~ "staging"* ]]; then
	# For staging branch
	KERNELTYPE=nightly
	KERNELNAME="Acrux-${KERNELRELEASE}-Nightly-${COMPILER_TYPE}-$(date +%Y%m%d-%H%M)"
        echo "CONFIG_LOCALVERSION="${KERNELNAME}"" >> arch/arm64/configs/acrux_defconfig
elif [[ "${PARSE_BRANCH}" =~ "pie"* ]]; then
	# For stable (pie) branch
	KERNELTYPE=stable
	ERNELNAME="Acrux-${KERNELRELEASE}-Release-${COMPILER_TYPE}-$(date +%Y%m%d-%H%M)"
	echo "CONFIG_LOCALVERSION="${KERNELNAME}"" >> arch/arm64/configs/acrux_defconfig
else
	# Dunno when this will happen but we will cover, just in case
	KERNELTYPE=${PARSE_BRANCH}
	KERNELNAME="Acrux-${KERNELRELEASE}-${PARSE_BRANCH}-${COMPILER_TYPE}-$(date +%Y%m%d-%H%M)"
        echo "CONFIG_LOCALVERSION="${KERNELNAME}"" >> arch/arm64/configs/acrux_defconfig
fi

export KERNELTYPE KERNELNAME

# Might as well export our zip
export ZIPNAME="${KERNELNAME}.zip"

# Our TG channels
CI_CHANNEL="-1001420038245"
TG_GROUP="-1001435271206"

# Send to main group
tg_groupcast() {
    "${TELEGRAM}" -c "${TG_GROUP}" -H \
    "$(
		for POST in "${@}"; do
			echo "${POST}"
		done
    )"
}

# sendcast to channel
tg_channelcast() {
    "${TELEGRAM}" -c "${CI_CHANNEL}" -H \
    "$(
		for POST in "${@}"; do
			echo "${POST}"
		done
    )"
}

# Let's announce our naisu new kernel!
tg_groupcast "Acrux compilation clocked at $(date +%Y%m%d-%H%M)!"
tg_channelcast "Compiler: <code>${COMPILER_STRING}</code>" \
	"Device: <b>${DEVICE}</b>" \
	"Kernel: <code>Acrux, release ${KERNELRELEASE}</code>" \
	"Branch: <code>${PARSE_BRANCH}</code>" \
	"Commit point: <code>${COMMIT_POINT}</code>" \
	"Under <code>${CIPROVIDER}</code>" \
	"Clocked at: <code>$(date +%Y%m%d-%H%M)</code>" \
	"Started on <code>$(whoami)</code>"

# Make is shit so I have to pass thru some toolchains
# Let's build, anyway
PATH="${KERNELDIR}/clang/bin:${PATH}"
START=$(date +"%s")
make O=out ARCH=arm64 acrux_defconfig
if [[ "${COMPILER_TYPE}" =~ "clang"* ]]; then
        make -j"${JOBS}" O=out ARCH=arm64 CC=clang CLANG_TRIPLE="aarch64-linux-gnu-" CROSS_COMPILE="${KERNELDIR}/gcc/bin/aarch64-linux-gnu-" CROSS_COMPILE_ARM32="${KERNELDIR}/gcc32/bin/arm-maestro-linux-gnueabi-"
elif [[ "${COMPILER_TYPE}" =~ "GCC10"* ]]; then
	make -j"${JOBS}" O=out ARCH=arm64 CROSS_COMPILE="${KERNELDIR}/gcc/bin/aarch64-raphiel-elf-" CROSS_COMPILE_ARM32="${KERNELDIR}/gcc32/bin/arm-maestro-linux-gnueabi-"
elif [[ "${COMPILER_TYPE}" =~ "GCC4.9"* ]]; then
	make -j"${JOBS}" O=out ARCH=arm64 CROSS_COMPILE="${KERNELDIR}/gcc/bin/aarch64-linux-android-"
else
	make -j"${JOBS}" O=out ARCH=arm64 CROSS_COMPILE="${KERNELDIR}/gcc/bin/aarch64-elf-" CROSS_COMPILE_ARM32="${KERNELDIR}/gcc32/bin/arm-eabi-"
fi

END=$(date +"%s")
DIFF=$(( END - START ))

# Copy our !!hopefully!! compiled kernel
cp "${OUTDIR}"/arch/arm64/boot/Image.gz-dtb "${ANYKERNEL}"/

# POST ZIP OR FAILURE
cd "${ANYKERNEL}" || exit
zip -r9 "${ZIPNAME}" *
CHECKER=$(ls -l "${ZIPNAME}" | awk '{print $5}')

if (($((CHECKER / 1048576)) > 5)); then
	"${TELEGRAM}" -f "$ZIPNAME" -c "${CI_CHANNEL}"
	tg_channelcast "Build for ${DEVICE} with ${COMPILER_STRING} took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)!"
	tg_groupcast "Build for ${DEVICE} with ${COMPILER_STRING} took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! @acruxci"
else
	tg_channelcast "Build for ${DEVICE} <b>failed</b> in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! Check Semaphore for errors!"
	tg_groupcast "Build for ${DEVICE} <b>failed</b> in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! Check Semaphore for errors! @acruxci" 
	exit 1;
fi
