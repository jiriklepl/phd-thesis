#!/bin/bash

# This script creates a compressed archive of the thesis

# make clean

declare -A files_to_archive=(
    ["*.tex"]=f
    ["*.bib"]=f
    ["img"]=d
)

src_dir="."

if [ "${1:-}" == "pdf" ]; then
    make all

    files_to_archive["thesis.pdf"]=f
    files_to_archive["abstract-en.pdf"]=f
    files_to_archive["abstract-cs.pdf"]=f
fi

find_files() {
    for pattern in "${!files_to_archive[@]}"; do
        type="${files_to_archive[$pattern]}"

        if [ "$type" == "f" ]; then
            find "$src_dir" -maxdepth 1 -type f -name "$pattern"
        elif [ "$type" == "d" ]; then
            find "$src_dir/$pattern" -type f
        else
            echo "Unknown type '$type' for pattern '$pattern'" >&2
            exit 1
        fi
    done
}

IFS=$'\n' read -r -d "\0" -a files < <(find_files)

# do a tar.gz archive
archive_name="thesis-archive.tar.gz"
if [ -f "$archive_name" ]; then
    rm "$archive_name"
fi
tar -czf "$archive_name" "${files[@]}"

# do a zip archive
zip_name="thesis-archive.zip"
if [ -f "$zip_name" ]; then
    rm "$zip_name"
fi
zip -r "$zip_name" "${files[@]}"
