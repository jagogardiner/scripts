#!/usr/bin/env bash
#
# Copyright (C) 2019 nysascape
#
# Licensed under the Raphielscape Public License, Version 1.c (the "License");
# you may not use this file except in compliance with the License.
#
# Semaphore build script for Acrux

# Make sure our branch is availiable
BRANCH=${PARSE_BRANCH}

# Make sure our fekking token is exported ig?
export TELEGRAM_TOKEN=${BOT_API_TOKEN}

# Some misc enviroment vars
DEVICE=Platina
CIPROVIDER=Semaphore

# Clone our AnyKernel3 branch to KERNELDIR
git clone https://github.com/nysascape/Acrux-AK3 -b master anykernel3
export ANYKERNEL=$(pwd)/anykernel3

# Do some silly defconfig replacements
if [[ "${BRANCH}" =~ "staging"* ]]; then
	# For staging branch
	export KERNELTYPE=nightly
	export KERNELNAME="Acrux-${RELEASE_VERSION}-Nightly-${COMPILER_TYPE}-$(date +%Y%m%d-%H%M)"
	sed -i "50s/.*/CONFIG_LOCALVERSION=""${KERNELNAME}""/g" arch/arm64/configs/acrux_defconfig
elif [[ "${BRANCH}" =~ "pie"* ]]; then
	# For stable (pie) branch
	export KERNELTYPE=stable
	export KERNELNAME="Acrux-${RELEASE_VERSION}-Release-${COMPILER_TYPE}-$(date +%Y%m%d-%H%M)"
	sed -i "50s/.*/CONFIG_LOCALVERSION=""${KERNELNAME}""/g" arch/arm64/configs/acrux_defconfig
else
	# Dunno when this will happen but we will cover, just in case
	export KERNELTYPE=${BRANCH}
	export KERNELNAME="Acrux-${RELEASE_VERSION}-${BRANCH}-${COMPILER_TYPE}-$(date +%Y%m%d-%H%M)"
	sed -i "50s/.*/CONFIG_LOCALVERSION=""${KERNELNAME}""/g" arch/arm64/configs/acrux_defconfig
fi

# Might as well export our zip
export ZIPNAME="${KERNELNAME}.zip"

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
tg_groupcast "Acrux ${KERNELTYPE} compilation clocked at $(date +%Y%m%d-%H%M)!"
tg_channelcast "Compiler: <code>${COMPILER_STRING}</code>" \
	"Device: <b>${DEVICE}</b>" \
	"Branch: <code>${BRANCH}</code>" \
	"Commit point: <code>${COMMIT_POINT}</code>" \
	"Under <code>${CIPROVIDER}</code" \
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
