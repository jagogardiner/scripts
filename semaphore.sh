#!/usr/bin/env bash
#
# Copyright (C) 2019 Raphielscape LLC.
#
# Licensed under the Raphielscape Public License, Version 1.c (the "License");
# you may not use this file except in compliance with the License.
#
# Semaphore build script for Acrux

# Enviroment variables
export KERNELDIR=${SEMAPHORE_PROJECT_DIR}

# Check if Clang is needed
if [[ "$@" =~ "clang" ]]; then
	export CC=Clang
else
	export CC=GCC
fi

# Just install proper packages
sudo install-package --update-new ccache bc bash git-core gnupg build-essential \
		zip curl make automake autogen autoconf autotools-dev libtool shtool python \
		m4 gcc libtool zlib1g-dev dash pigz

# Just to make sure bc Semaphore can be drunk
cd ${KERNELDIR} 
