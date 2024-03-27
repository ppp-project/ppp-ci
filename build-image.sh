#!/bin/sh

# Exit if any error occurs
set -e

PrintMessage()
{
	printf "\033[33m--> $1\033[0m\n"
}

BUILDROOT_VERSION=2024.02

# Check arguments
if [ $# -ne 3 ]
then
	echo "Usage : $0 buildroot_defconfig_name libc_name output_directory"
	echo "  buildroot_defconfig_name : see all available defconfigs here https://git.busybox.net/buildroot/tree/configs?h=${BUILDROOT_VERSION}"
	echo "  libc_name : must be \"glibc\", \"uclibc\" or \"musl\""
	echo "  output_directory : will contain the build directory and the final compressed artifacts"
	exit 1
fi
DEFCONFIG_NAME="$1"
LIBC_NAME="$2"
OUTPUT_DIRECTORY="$3"

# Create the build directory name
BUILD_DIRECTORY_NAME="buildroot-${DEFCONFIG_NAME}-${LIBC_NAME}"
BUILD_DIRECTORY_PATH=$(realpath "${OUTPUT_DIRECTORY}")/"${BUILD_DIRECTORY_NAME}"

PrintMessage "Removing previous build artifacts..."
rm -rf "${BUILD_DIRECTORY_PATH}"

PrintMessage "Downloading Buildroot sources..."
git clone --depth=1 --branch="${BUILDROOT_VERSION}" https://github.com/buildroot/buildroot "${BUILD_DIRECTORY_PATH}"

PrintMessage "Modifying the PPP Buildroot package to use upstream PPP sources..."
PPP_PACKAGE_PATH="${BUILD_DIRECTORY_PATH}/package/pppd"
# Upstream version always needs OpenSSL
sed -i '/select BR2_PACKAGE_OPENSSL/c\\select BR2_PACKAGE_OPENSSL' ${PPP_PACKAGE_PATH}/Config.in
# Do not check for package hash, so there is no need to compute it
rm ${PPP_PACKAGE_PATH}/pppd.hash
# Buildroot patches are already applied upstream
rm -f ${PPP_PACKAGE_PATH}/*.patch
# Get package sources from head of master branch
LAST_COMMIT_HASH=$(curl -s -H "Accept: application/vnd.github.VERSION.sha" "https://api.github.com/repos/ppp-project/ppp/commits/master")
sed -i "/PPPD_VERSION =/c\\PPPD_VERSION = ${LAST_COMMIT_HASH}" ${PPP_PACKAGE_PATH}/pppd.mk
sed -i '/PPPD_SITE =/c\\PPPD_SITE = https://github.com/ppp-project/ppp' ${PPP_PACKAGE_PATH}/pppd.mk
sed -i '9iPPPD_SITE_METHOD = git' ${PPP_PACKAGE_PATH}/pppd.mk

PrintMessage "Enabling PPP build in Buildroot configuration..."
# Enable all Buildroot PPP options as everything is built by upstream build system
echo "BR2_PACKAGE_PPPD=y" >> ${BUILD_DIRECTORY_PATH}/configs/${DEFCONFIG_NAME}
echo "BR2_PACKAGE_PPPD_FILTER=y" >> ${BUILD_DIRECTORY_PATH}/configs/${DEFCONFIG_NAME}

PrintMessage "Selecting the ${LIBC_NAME} C library..."
case $LIBC_NAME in
	"glibc")
		echo "BR2_TOOLCHAIN_BUILDROOT_GLIBC=y" >> "${BUILD_DIRECTORY_PATH}/configs/${DEFCONFIG_NAME}"
		;;
	"uclibc")
		echo "BR2_TOOLCHAIN_BUILDROOT_UCLIBC=y" >> "${BUILD_DIRECTORY_PATH}/configs/${DEFCONFIG_NAME}"
		;;
	"musl")
		echo "BR2_TOOLCHAIN_BUILDROOT_MUSL=y" >> "${BUILD_DIRECTORY_PATH}/configs/${DEFCONFIG_NAME}"
		;;
	*)
		echo "Unknown C library, please specify \"glibc\", \"uclibc\" or \"musl\"."
		exit 1
		;;
esac

PrintMessage "Generating the Buildroot configuration..."
cd "${BUILD_DIRECTORY_PATH}"
make "${DEFCONFIG_NAME}"

PrintMessage "Building the Buildroot image..."
make
