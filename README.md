# c1trus

An untethered/tethered downgrader for A7 and A8 devices.

Supports only macOS. Linux support is under development...

Follow on Instagram! 
https://www.instagram.com/c1trus.officieel?igsh=eGVic2hjOXZkODNh&utm_source=qr

# Supported devices and versions:

iPhone 6 and 6 Plus

iOS 8.3-8.4.1 (tethered-sepless)

iOS 10.3-10.3.3 (tethered-partially with sep)

iPhone 5S (both of iPhone6,1 and 6,2)

iOS 10.3.3 (untethered-with sep)

# Usage:

Download the latest release.

First: ` sudo chmod +x c1trus.sh `
Then run: ` ./c1trus.sh `

# Dyld fix:

First boot the SSH ramdisk from Legacy iOS Kit or sshrd_script.

On Legacy-iOS-Kit

Connect to SSH
Run : ` cd .. ` 3 times.
Run : ` mount -t hfs /dev/disk0s1s1 /mnt1 `
Open an another terminal window.
Run : ` iproxy 2222 22 `
Wait 3-4 seconds.
Open an another terminal window.
You can get dsc64patcher from Semaphorin's binaries:
(https://github.com/LukeZGD/Semaphorin)
Run : 
` scp -P2222 root@localhost:/mnt1/System/Library/Caches/com.apple.dyld/dyld_shared_cache_arm64 dyld.raw `

` ./dsc64patcher dyld.raw dyld.patched -8 `

` scp -P2222 dyld.patched root@localhost:/mnt1/System/Library/Caches/com.apple.dyld/dyld_shared_cache_arm64 `

Then close the second and third page.
Run : ` cd .. `
Run : ` umount mnt1 `
And exit.

On sshrd_script

Run : ` ./sshrd.sh 12.0 `
Run : ` ./sshrd.sh boot `
Run : ` ./sshrd.sh ssh `
Run : ` mount_hfs /dev/disk0s1s1 /mnt1 `
Open an another terminal window.
Run : ` iproxy 2222 22 `
Wait 3-4 seconds.
Open an another terminal window.
You can get dsc64patcher from Semaphorin's binaries:
(https://github.com/LukeZGD/Semaphorin)
Run : 
` scp -P2222 root@localhost:/mnt1/System/Library/Caches/com.apple.dyld/dyld_shared_cache_arm64 dyld.raw `

` ./dsc64patcher dyld.raw dyld.patched -8 `

` scp -P2222 dyld.patched root@localhost:/mnt1/System/Library/Caches/com.apple.dyld/dyld_shared_cache_arm64 `

Then close the second and third page.
Run : ` cd .. `
Run : ` umount mnt1 `
And exit.

# Thanks to:

libimobiledevice team, tihmstar, LukeeGD/LukeZGD, xerub, plooshi and synackuk

# Special thanks to: 

HeliX
