#!/bin/sh
file=${1:-thesis}
gs -dCompatibilityLevel=1.4 -dCompressFonts=true -dSubsetFonts=true -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dDownsampleColorImages=true -dColorImageResolution=300 -sOutputFile=${file}_compressed.pdf ${file}.pdf 
