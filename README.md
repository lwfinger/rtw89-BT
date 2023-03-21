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
Users of Debian, Ubuntu, and similar (Mint etc) may want to scroll down and follow the DKMS instructions at the end of this document instead.

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


# DKMS packaging for debian and derivatives

DKMS is commonly used on debian and derivatives, like ubuntu, to streamline building extra kernel modules.  
By following the instructions below and installing the resulting package, the rtw89 driver will automatically rebuild on kernel updates. Secure boot signing will happen automatically as well, 
as long as the dkms signing key (usually located at /var/lib/dkms/mok.key) is enrolled. See your distro's secure boot documentation for more details. 


Prerequisites:


``` bash
sudo apt install dh-sequence-dkms debhelper build-essential devscripts
```

This workflow uses devscripts, which has quite a few perl dependencies.  
You may wish to build inside a chroot to avoid unnecessary clutter on your system. The debian wiki page for [chroot](https://wiki.debian.org/chroot) has simple instructions for debian, which you can adapt to other distros as needed by changing the release codename and mirror url.  
If you do, make sure to install the package on your host system, as it will fail if you try to install inside the chroot. 

Build and installation

```bash
# If you've already built as above clean up your workspace or check one out specially (otherwise some temp files can end up in your package)
git clean -xfd

git deborig HEAD
dpkg-buildpackage -us -uc
sudo apt install ../rtw89bt-dkms_1.0.0_all.deb
```

This will install the package, and build the module for your
currently active kernel. The new module will load automatically on boot. 
You can also load it right away, but because it has the same module name
as the mainline bluetooth usb driver, that one needs to be unloaded first.
This can be done with the following commands:
```bash
sudo modprobe -rv btusb
sudo modprobe -v btusb
```

##### A note regarding firmware

Firmware from userspace is required to use this driver. This package will attempt to pull the firmware in automatically as a Recommends.
However, if your distro does not provide one of firmware-realtek >= 20230117-1 or linux-firmware >= 20220329.git681281e4-0ubuntu3.10, 
the driver will fail to load, and dmesg will show an error about a specific missing firmware file. In this case, you can download the firmware files 
directly from https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/rtl_bt.

