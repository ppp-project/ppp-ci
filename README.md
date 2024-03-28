# PPP Buildroot CI images

A Buildroot-based CI that allows checking PPP build against various CPU architectures and C libraries.  
This repository contains the script to generate customized prebuilt Buildroot images that are used by a GitHub action in the PPP repository.  
The prebuilt Buildroot images are automatically generated then stored in this repository [releases](https://github.com/ppp-project/ppp-ci/releases) section.

## Requirements

The script in this repository is designed to run on **Ubuntu 22.04**.  
Make sure the following packages are installed :
```
sudo apt install build-essential curl git zstd
```

## Usage

Run the `build-image.sh` script from your current user account (there is no need to be `root`) :
```
cd path/to/ppp-ci
./build-image.sh <buildroot defconfig> <C library name> <output directory>
```

Run `build-image.sh` without parameter to display the embedded help.
