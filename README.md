# rtw89-BT
Out-of-kernel driver for Realtek BT devices found in rtw89 devides.

This driver will build for kernels 5.15+.
If you get build errors, please report them in this repo as an issue.
I will make every attempt to backport the code to older kernels.

The repository contains BT drivers for the known BT parts of the following:

Realtek 8852AE, RTW8852BE, and RTW8852CE.

### Installation instruction
##### Requirements
You will need to install "make", "gcc", "kernel headers", "kernel build essentials", and "git".

For **Ubuntu**: You can install them with the following command
```bash
sudo apt-get update
sudo apt-get install make gcc linux-headers-$(uname -r) build-essential git
```
For **Fedora**: You can install them with the following command
```bash
sudo dnf install kernel-headers kernel-devel
sudo dnf group install "C Development Tools and Libraries"
```
For **openSUSE**: Install necessary headers with
```bash
sudo zypper install make gcc kernel-devel kernel-default-devel git libopenssl-devel

##### Installation
For all distros:
```bash
git clone git@github.com:lwfinger/rtw89-BT.git
cd rtw89-BT
make
sudo make install
```

##### Installation with module signing for SecureBoot
For all distros:
```bash
git clone git@github.com:lwfinger/rtw89-BT.git
cd rtw89-BT
make
sudo make sign-install
```
You will be promted a password, please keep it in mind and use it in next steps.
Reboot to activate the new installed module.
In the MOK managerment screen:
1. Select "Enroll key" and enroll the key created by above sign-install step
2. When promted, enter the password you entered when create sign key. 
3. If you enter wrong password, your computer won't not bebootable. In this case,
   use the BOOT menu from your BIOS, to boot into your OS then do below steps:
```bash
sudo mokutil --reset
```
Restart your computer
Use BOOT menu from BIOS to boot into your OS
In the MOK managerment screen, select reset MOK list
Reboot then retry from the step make sign-install


# DKMS packaging for ubuntu/debian

DKMS on debian/ubuntu simplifies the secure-boot issues, signing is
taken care of through the same mechanisms as nVidia and drivers.  You
won't need special reboot and MOK registration.

Additionally DKMS ensures new kernel installations will automatically
rebuild the driver, so you can accept normal kernel updates.

Prerequisites:

A few packages are required to build the debs from source:

``` bash
sudo apt install dkms debhelper dh-modaliases
```

Build and installation

```bash
# If you've already built as above clean up your workspace or check one out specially (otherwise some temp files can end up in your package)
git clean -xfd

dpkg-buildpackage -us -uc
sudo apt install ../rtw89bt-dkms_1.0.0_all.deb  ../rtw89bt-firmware_1.0.0_all.deb
```

That should install the package, and build the module for your
currently active kernel.  You should then be able to remove an
old version and load the new one with the following:
```bash
sudo modprobe -rv btusb
sudo modprobe -v btusb
```

above.
