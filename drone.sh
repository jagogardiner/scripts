#!/bin/bash
#
# Copyright (C) 2019 nysascape
#
# Licensed under the Raphielscape Public License, Version 1.c (the "License");
# you may not use this file except in compliance with the License.
#
# Drone build script for Acrux

# shellcheck source=/dev/null
. "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/envsetup.sh

# Clone our AnyKernel3 branch to KERNELDIR
git clone https://github.com/nysascape/Acrux-AK3 -b master anykernel3

# Clone Telegram binaries
git clone https://github.com/fabianonline/telegram.sh/ telegram

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

mkdir "${KERNELDIR}"/out

##Cache the out dir
ln -s "${SEMAPHORE_CACHE_DIR}"/out "${KERNELDIR}"/out
rm -rf "${OUTDIR}"/arch/arm64/boot/Image.gz-dtb

make O=out ARCH=arm64 acrux_defconfig
if [[ "${COMPILER_TYPE}" =~ "clang"* ]]; then
        make -j"${JOBS}" O=out ARCH=arm64 CC=clang CLANG_TRIPLE="aarch64-linux-gnu-" CROSS_COMPILE="${KERNELDIR}/gcc/bin/aarch64-linux-gnu-" CROSS_COMPILE_ARM32="${KERNELDIR}/gcc32/bin/arm-maestro-linux-gnueabi-"
elif [[ "${COMPILER_TYPE}" =~ "GCC10"* ]]; then
	make -j"${JOBS}" O=out ARCH=arm64 CROSS_COMPILE="${KERNELDIR}/gcc/bin/aarch64-raphiel-elf-" CROSS_COMPILE_ARM32="${KERNELDIR}/gcc32/bin/arm-maestro-linux-gnueabi-"
elif [[ "${COMPILER_TYPE}" =~ "GCC4.9"* ]]; then
	make -j"${JOBS}" O=out ARCH=arm64 CROSS_COMPILE="${KERNELDIR}/gcc/bin/aarch64-linux-android-"
else
	make -j"${JOBS}" O=out ARCH=arm64 CROSS_COMPILE="${KERNELDIR}/gcc/bin/aarch64-maestro-linux-gnu-" CROSS_COMPILE_ARM32="${KERNELDIR}/gcc32/bin/arm-maestro-linux-gnueabi-"
fi

END=$(date +"%s")
DIFF=$(( END - START ))

## Check if compilation is done successfully.

if ! [ -f "${OUTDIR}"/arch/arm64/boot/Image.gz-dtb ]; then
	echo -e "Kernel compilation failed, See buildlog to fix errors"
	tg_channelcast "Build for ${DEVICE} <b>failed</b> in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! Check Semaphore for errors!"
	tg_groupcast "Build for ${DEVICE} <b>failed</b> in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! Check Semaphore for errors @nysascape! @acruxci"
	exit 1
fi

# Copy our !!hopefully!! compiled kernel
cp "${OUTDIR}"/arch/arm64/boot/Image.gz-dtb "${ANYKERNEL}"/

# POST ZIP OR FAILURE
cd "${ANYKERNEL}" || exit
command zip -rT9 "${TEMPZIPNAME}" -- *

## Sign the zip before sending it to telegram
curl -sLo zipsigner-3.0.jar https://raw.githubusercontent.com/baalajimaestro/AnyKernel2/master/zipsigner-3.0.jar
java -jar zipsigner-3.0.jar "${TEMPZIPNAME}" "${ZIPNAME}"

"${TELEGRAM}" -f "$ZIPNAME" -c "${CI_CHANNEL}"
tg_channelcast "Build for ${DEVICE} with ${COMPILER_STRING} took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)!"
tg_groupcast "Build for ${DEVICE} with ${COMPILER_STRING} took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! @acruxci"
