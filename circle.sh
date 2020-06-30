#!/usr/bin/env bash
# Copyright (C) 2019-2020 Jago Gardiner (nysascape)
#
# Licensed under the Raphielscape Public License, Version 1.d (the "License");
# you may not use this file except in compliance with the License.
#
# CI build script

# Needed exports
export TELEGRAM_TOKEN=${BOT_API_TOKEN}
export ANYKERNEL=$(pwd)/anykernel3

# Avoid hardcoding things
KERNEL=nysa
DEFCONFIG=b1c1_defconfig
DEVICES_TO_COMPILE="Pixel 3/XL, Pixel 3a/XL"
DEVICE="Pixel3"
DEVICE_PRETTY="Pixel 3 (XL)"
CIPROVIDER=CircleCI
PARSE_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PARSE_ORIGIN="$(git config --get remote.origin.url)"
COMMIT_POINT="$(git log --pretty=format:'%h : %s' -1)"

# Kernel groups
CI_CHANNEL=-1001308609321
TG_GROUP=-1001401121422

# Clang is annoying
PATH="${KERNELDIR}/clang/bin:${PATH}"

# Init submodules
git submodule update --init --recursive

# Function to replace defconfig versioning
setversioning() {
    # For staging branch
	KERNELTYPE=nightly
	KERNELNAME="${KERNEL}-${DEVICE}-$(date +%y%m%d-%H%M)-Nightly"
	sed -i "50s/.*/CONFIG_LOCALVERSION=\"-${KERNELNAME}\"/g" arch/arm64/configs/${DEFCONFIG}

    # Export our new localversion and zipnames
    export KERNELTYPE KERNELNAME
    export TEMPZIPNAME="${KERNELNAME}-unsigned.zip"
    export ZIPNAME="${KERNELNAME}.zip"
}

# Send to main group
tg_groupcast() {
    "${TELEGRAM}" -c "${TG_GROUP}" -H \
    "$(
		for POST in "${@}"; do
			echo "${POST}"
		done
    )"
}

# Send to channel
tg_channelcast() {
    "${TELEGRAM}" -c "${CI_CHANNEL}" -H \
    "$(
		for POST in "${@}"; do
			echo "${POST}"
		done
    )"
}

# Fix long kernel strings
kernelstringfix() {
    git config --global user.name "nysascape"
    git config --global user.email "jago@nysascape.digital"
    git add .
    git commit -m "stop adding dirty"
}

# Make the kernel
makekernel() {
    # Clean any old AnyKernel
    rm -rf ${ANYKERNEL}
    git clone https://github.com/nysascape/AnyKernel3 -b master anykernel3
    kernelstringfix
    make O=out ARCH=arm64 ${DEFCONFIG}
    make -j$(nproc --all) CC=clang CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- O=out ARCH=arm64

    # Check if compilation is done successfully.
    if ! [ -f "${OUTDIR}"/arch/arm64/boot/Image.lz4-dtb ]; then
	    END=$(date +"%s")
	    DIFF=$(( END - START ))
	    echo -e "Kernel compilation failed, See buildlog to fix errors"
	    tg_channelcast "Build for ${DEVICE_PRETTY} <b>failed</b> in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! Check ${CIPROVIDER} for errors!"
	    tg_groupcast "Build for ${DEVICE_PRETTY} <b>failed</b> in $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)! Check ${CIPROVIDER} for errors @nysascape!"
	    exit 1
    fi
}

# Ship the compiled kernel
shipkernel() {
    # Copy compiled kernel
    cp "${OUTDIR}"/arch/arm64/boot/Image.lz4-dtb "${ANYKERNEL}"/

    # Zip the kernel, or fail
    cd "${ANYKERNEL}" || exit
    zip -r9 "${TEMPZIPNAME}" *

    # Sign the zip before sending it to Telegram
    curl -sLo zipsigner-3.0.jar https://raw.githubusercontent.com/baalajimaestro/AnyKernel2/master/zipsigner-3.0.jar
    java -jar zipsigner-3.0.jar ${TEMPZIPNAME} ${ZIPNAME}

    # Ship it to the CI channel
    "${TELEGRAM}" -f "$ZIPNAME" -c "${CI_CHANNEL}"

    # Go back for any extra builds
    cd ..
}

gcast() {
    tg_groupcast "${DEVICE} kernel compilation clocked at $(date +%Y%m%d-%H%M)!"
}

ccast() {
    tg_channelcast "Device(s): <b>${DEVICES_TO_COMPILE}</b>" \
        "Kernel: <code>${KERNEL}, release ${KERNELTYPE}</code>" \
        "Compiler: <code>${COMPILER_STRING}</code>" \
    	"Branch: <code>${PARSE_BRANCH}</code>" \
    	"Commit point: <code>${COMMIT_POINT}</code>" \
    	"Clocked at: <code>$(date +%Y%m%d-%H%M)</code>"
}

## Start the kernel buildflow ##
setversioning
ccast
tg_channelcast "Compiling ${DEVICE_PRETTY}..."
gcast
START=$(date +"%s")
makekernel || exit 1
shipkernel
DEVICE="Pixel3a"
DEVICE_PRETTY="Pixel 3a (XL)"
DEFCONFIG=b4s4_defconfig
setversioning
tg_channelcast "Compiling ${DEVICE_PRETTY}..."
makekernel || exit 1
shipkernel
END=$(date +"%s")
DIFF=$(( END - START ))
tg_channelcast "Build(s) for ${DEVICES_TO_COMPILE} with ${COMPILER_STRING} took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)!"
tg_groupcast "Build(s) for ${DEVICES_TO_COMPILE} with ${COMPILER_STRING} took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)!"
