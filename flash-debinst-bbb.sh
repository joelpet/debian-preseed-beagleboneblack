#!/usr/bin/env bash
set -eu -o pipefail

main() {
    for cmd in make pv tee; do
        if ! command -v "${cmd}" > /dev/null 2>&1; then
            echo >&2 "Missing dependency: Couldn't locate ${cmd}."
            exit 1
        fi
    done

    local mmcblk_dev=${1?Missing argument: SD card device}
    local release=${2:-buster}
    local version=${3:-current}
    local variant=${4:-netboot}

    [[ -b "${mmcblk_dev}" ]] || { echo >&2 "${mmcblk_dev} is not a block device."; exit 1; }

    case "${variant}" in
        hd-media)
            cat >&2 <<EOF
--------------------------------------------------------------------------------
Remember to download a Debian installation ISO from
https://cdimage.debian.org/cdimage/ and copy it onto the flashed SD card before
booting your BeagleBone Black from it.
--------------------------------------------------------------------------------
EOF
        ;;
        netboot) ;;
        *) echo >&2 "Invalid installer SD card image variant: ${variant}" ;;
    esac

    make "out/${variant}.img" "RELEASE=${release}" "VERSION=${version}"

    read -p "Overwrite data on device ${mmcblk_dev}? [y|N] " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pv < "out/${variant}.img" | sudo tee "${mmcblk_dev}" > /dev/null
        sync
    fi
}

main "$@"
