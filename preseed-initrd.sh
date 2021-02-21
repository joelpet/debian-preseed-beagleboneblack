#!/usr/bin/env bash
set -eu -o pipefail

main() {
    readonly preseed_file=${1?Missing argument: Preseed configuration file name}
    readonly initrd_file=${2?Missing argument: initrd.gz file on SD card}

    [[ -f "${preseed_file:-}" ]] || { echo >&2 "Not a file: ${preseed_file}"; exit 1; }

    readonly tmp_dir=$(mktemp --directory --suffix=.preseed-sd-card)
    readonly tmp_initrd_file="${tmp_dir}/initrd"

    gunzip --to-stdout "${initrd_file}" > "${tmp_initrd_file}"
    (
        cd "${tmp_dir}"
        cp "${preseed_file}" "preseed.cfg"
        echo "preseed.cfg" | cpio --format=newc --create --append --file="${tmp_initrd_file}"
    )
    gzip --to-stdout "${tmp_initrd_file}" > "${initrd_file}"
}

main "$@"
