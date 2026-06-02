#!/usr/bin/env bash

set -euo pipefail

python3 -m venv .venv
source .venv/bin/activate

OLD_DIR=$(pwd)
NEW_DIR="dist"
PDF_NAME="thesis"

BIBLIOGRAPHY_FILE="bibliography.bib"
STYLE_FILES=("metadata.tex" "xmp.tex" "papers/")

BIBLIOGRAPHY_COMMAND="biber"

python3 -m pip install latex-flatten

rm -rf "${NEW_DIR}"

pushd "${OLD_DIR}" >/dev/null

rm -f "${PDF_NAME}.aux" "${PDF_NAME}.bbl" "${PDF_NAME}.blg" "${PDF_NAME}.fdb_latexmk" "${PDF_NAME}.fls" "${PDF_NAME}.log" "${PDF_NAME}.out" "${PDF_NAME}.synctex".gz

pdflatex "${PDF_NAME}.tex"
${BIBLIOGRAPHY_COMMAND} "${PDF_NAME}"
pdflatex "${PDF_NAME}.tex"
pdflatex "${PDF_NAME}.tex"
sleep 1

popd >/dev/null

python3 -m latex_flatten --outdir "${NEW_DIR}" "${OLD_DIR}/${PDF_NAME}.tex"
cp -rt "${NEW_DIR}" "${BIBLIOGRAPHY_FILE}" "${STYLE_FILES[@]}"

pushd "${NEW_DIR}" >/dev/null

rm -f "${PDF_NAME}.aux" "${PDF_NAME}.bbl" "${PDF_NAME}.blg" "${PDF_NAME}.fdb_latexmk" "${PDF_NAME}.fls" "${PDF_NAME}.log" "${PDF_NAME}.out" "${PDF_NAME}.synctex".gz

pdflatex "${PDF_NAME}.tex"
${BIBLIOGRAPHY_COMMAND} "${PDF_NAME}"
pdflatex "${PDF_NAME}.tex"
pdflatex "${PDF_NAME}.tex"
sleep 1

popd >/dev/null

if which diffpdf >/dev/null; then
    diffpdf "${PDF_NAME}.pdf" "${OLD_DIR}/${PDF_NAME}.pdf"
else
    echo "diffpdf not found, skipping PDF comparison" >&2
fi
