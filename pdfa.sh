#!/usr/bin/env bash

# Make a PDF safe to import into the thesis's PDF/A-2u document.
#
# Ghostscript's pdfwrite PDF/A conversion retains nonconforming font objects
# from some publisher PDFs (including missing Unicode maps and invalid glyph
# widths).  Rendering each page as an RGB image removes those objects.  The
# output is an image-only facsimile intended for inclusion in thesis.pdf; the
# outer pdfx document supplies the PDF/A identification and output intent.

set -euo pipefail

if (( $# < 1 || $# > 2 )); then
  echo "Usage: $0 INPUT.pdf [OUTPUT.pdf]" >&2
  exit 2
fi

input=$1
output=${2:-"pdfa-$(basename -- "$input")"}
dpi=${PDFA_DPI:-200}
jpeg_quality=${PDFA_JPEG_QUALITY:-95}
temporary="$output.tmp"

if [[ ! -f "$input" ]]; then
  echo "Input PDF not found: $input" >&2
  exit 2
fi

mkdir -p "$(dirname -- "$output")"
trap 'rm -f "$temporary"' EXIT

gs -q -dSAFER -dBATCH -dNOPAUSE \
  -sDEVICE=pdfimage24 \
  -r"$dpi" \
  -dJPEGQ="$jpeg_quality" \
  -sOutputFile="$temporary" \
  "$input"

mv "$temporary" "$output"
trap - EXIT
