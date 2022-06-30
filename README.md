# rtw89-BT
Out-of-kernel driver for Realtek BT devices found in rtw89 devides.

This driver has not been tested (yet) for builds with older kernels.
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


