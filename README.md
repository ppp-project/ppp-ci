# PPP Continuous Integration

A Buildroot-based CI that allows checking PPP build against various CPU architectures and C libraries.  
This repository contains scripts to generate customized prebuilt Buildroot images that are used by a GitHub action in the PPP repository.  
The prebuilt Buildroot images are also stored in this repository releases section.

## Requirements

The scripts in this repository are designed to run on **Ubuntu 22.04**.  
Make sure the following packages are installed :
```
sudo apt install build-essential curl git zstd
```

Your host build machine architecture must be **amd64/x86_64**, otherwise the generated Buildroot images won't run in the GitHub runner containers.  

The Buildroot images will be built in the `/home/runner` directory to match the GitHub runners user name.
Make sure the `/home/runner` directory is existing and can be accessed by the scripts (there is no need of creating a specific `runner` user) :
```
sudo mkdir -p /home/runner
sudo chown $USER:$USER /home/runner
```

## Usage

Run the `build-all-targets.sh` from your current user account (there is no need to be `root`) :
```
cd path/to/ppp-ci
./build-all-targets.sh
```

Wait patiently, you will get all the Buildroot compressed images (`.zst`) in the `/home/runner` directory.
