#!/bin/bash

# This script creates a compressed archive of the thesis

# make clean

files_to_archive=(
    "*.tex"
    "*.bib"
)

src_dir="."

if [ "${1:-}" == "pdf" ]; then
    make all
    files_to_archive+=("thesis.pdf" "abstract-en.pdf" "abstract-cs.pdf")
fi

find_files() {
    for pattern in "${files_to_archive[@]}"; do
        find "$src_dir" -maxdepth 1 -type f -name "$pattern"
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
zip -j "$zip_name" "${files[@]}"
