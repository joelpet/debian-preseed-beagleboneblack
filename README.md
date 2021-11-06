# Debian preseed BeagleBone Black

This is a utility to aid in preseeding the installation of Debian on the BeagleBone Black.

## Usage

1. Download and flash Debian installation SD card image to a memory card.

    ./flash-debinst-bbb.sh <mmcblk_dev> [release=buster [version=current [variant=netboot]]]

2. Add preseed file to initrd.

    ./preseed-initrd.sh <preseed_file> <initrd_gz_file>

## Troubleshooting

### Kernel modules not found during installation

If, after "Downloading Release Files...", a warning is shown about missing kernel modules, try starting over with a fresh SD card image.
First, delete the old ones by running `make clean`.
Then, start over from the beginning.

## Resources

https://www.debian.org/releases/stable/armhf/apb.en.html

## TODO

### Template preseed.cfg

Allow inserting things like passwd/user-password-crypted during a templating run.

### Reduce the number of manual steps

The UI should really only be:

    $ ./flash-debinst-bbb [--preseed preseed.cfg] <mmcblk-dev>
    Overwrite all data on device <mmcblk-dev>? [y|N]: y
    $ echo $status
    0

### Validate preseed.cfg

debconf-set-selections -c preseed.cfg


### Create file from after installation

1. Do the installation manually.
2. Reboot
3. Install debconf-utils package.
2. Get the debconf selections.

From https://www.debian.org/releases/stable/armhf/apbs03.en.html:

    An alternative method is to do a manual installation and then, after rebooting, use the debconf-get-selections from the debconf-utils package to dump both the debconf database and the installer's cdebconf database to a single file:

    $ echo "#_preseed_V1" > file
    $ debconf-get-selections --installer >> file
    $ debconf-get-selections >> file

    However, a file generated in this manner will have some items that should not be preseeded, and the example file is a better starting place for most users.
    [Note] 	Note

    This method relies on the fact that, at the end of the installation, the installer's cdebconf database is saved to the installed system in /var/log/installer/cdebconf. However, because the database may contain sensitive information, by default the files are only readable by root.

    The directory /var/log/installer and all files in it will be deleted from your system if you purge the package installation-report.

## License

GNU General Public License v3.0 or later.

See COPYING to see the full text.
