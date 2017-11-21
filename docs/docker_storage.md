## Docker storage setup
-----------------------

### RHEL:

By default, Docker puts data and metadata on a loop device backed by a sparse file.	This is great from a usability point of view (zero configuration needed) but terrible from a performance point of view.
To resolve this, real block devices should be provisioned for docker and docker needs to be configured to use direct-lvm storage driver.

To provision this, docker needs an unmounted storage space. If you already have unmounted storage available in your machine, skip to last step!

1.  Following commands lists the mounted devices, 
```
df -aTh
```
2.  The device can be unmounted using the following command where /dev/sdb is the storage required.
```
umount /dev/sdb
```
If any process is restricting it from being mounted you can check for other mountpoints and check for blocking processes by following commands
```
fuser /dev/sdb
lsof /dev/sdb
```
3.  After unmounting you can give input or append in existing ansible install command as follows.
This will **format** the /dev/sdb storage and provision it to be used with docker. Any data inside the partrition would be destroyed.
```
DirectLVMstorage=yes Docker_storage_devs=/dev/sdb
```
Docker daemon would also be configured by ansible script to use the specified volume as image and container storage.
