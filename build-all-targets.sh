#!/bin/sh

# Exit if any error occurs
set -e

PrintMessage()
{
	printf "\033[35m-> $1\033[0m\n"
}

# Building Buildroot in the same path that it will run in a GitHub runner is mandatory for the absolute paths generated by Buildroot during build to work on the GitHub runner
OUTPUT_DIRECTORY=/home/runner

# Make sure the output directory exists
if [ ! -d "$OUTPUT_DIRECTORY" ]
then
	echo "Error : the output directory $OUTPUT_DIRECTORY must be created and must be accessible to this script."
	echo "This output directory can't be changed, otherwise Buildroot won't run in a GitHub runner."
	exit 1
fi

# Make sure the host machine architecture is the same that the GitHub runners one
if [ "$(uname -m)" != "x86_64" ]
then
	echo "Error : the host build machine architecture must be x86_64."
	exit 1
fi

DEFCONFIG_NAMES="qemu_x86_defconfig qemu_x86_64_defconfig raspberrypi4_defconfig raspberrypi4_64_defconfig qemu_ppc64le_pseries_defconfig qemu_mips32r2_malta_defconfig qemu_mips64_malta_defconfig"
LIBC_NAMES="glibc uclibc musl"

# Build all possible configurations
for Defconfig in $DEFCONFIG_NAMES
do
	for Libc in $LIBC_NAMES
	do
		PrintMessage "Building '$Defconfig' defconfig with '$Libc' libc..."
		./build-buildroot.sh $Defconfig $Libc $OUTPUT_DIRECTORY

		PrintMessage "Compressing Buildroot build..."
		Buildroot_Build_Name=buildroot-${Defconfig}-${Libc}
		cd $OUTPUT_DIRECTORY
		tar -c $Buildroot_Build_Name -f ${Buildroot_Build_Name}.tar
		rm -f ${Buildroot_Build_Name}.tar.zstd
		zstd -T0 -19 --rm -v ${Buildroot_Build_Name}.tar
		cd -
	done
done