#!/usr/bin/env bash

# Make a PDF safe to import into the thesis's PDF/A-2u document.
#
# Ghostscript's pdfwrite PDF/A conversion retains nonconforming font objects
# from some publisher PDFs (including missing Unicode maps and invalid glyph
# widths). Rendering each page as a losslessly compressed RGB image removes
# those objects. The output is an image-only facsimile intended for inclusion
# in thesis.pdf; the outer pdfx document supplies the PDF/A identification and
# output intent.

set -euo pipefail

if (( $# < 1 || $# > 2 )); then
  echo "Usage: $0 INPUT.pdf [OUTPUT.pdf]" >&2
  exit 2
fi

input=$1
output=${2:-"pdfa-$(basename -- "$input")"}
dpi=${PDFA_DPI:-300}
compression=${PDFA_COMPRESSION:-Flate}
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
  -sCompression="$compression" \
  -sOutputFile="$temporary" \
  "$input"

mv "$temporary" "$output"
trap - EXIT
