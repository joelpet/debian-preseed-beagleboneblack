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
    local variant=${2:-netboot}

    [[ -b "${mmcblk_dev}" ]] || { echo >&2 "${mmcblk_dev} is not a block device."; exit 1; }

    case "${variant}" in
        hd-media)
            echo >&2 "Warning: hd-media is not yet working; installer can not find ISO" ;;
        netboot) ;;
        *) echo >&2 "Invalid installer SD card image variant: ${variant}" ;;
    esac

    make "out/${variant}.img"

    read -p "Overwrite data on device ${mmcblk_dev}? [y|N] " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pv < "out/${variant}.img" | sudo tee "${mmcblk_dev}" > /dev/null
        sync
    fi
}

main "$@"
