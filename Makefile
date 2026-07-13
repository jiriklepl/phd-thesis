#!/usr/bin/make -f

eps = $(patsubst img/%.svg,img/%.eps,$(wildcard img/*.svg))
paper_sources = $(wildcard papers/*.pdf)
archival_papers = $(patsubst papers/%.pdf,papers/pdfa/%.pdf,$(paper_sources))

ARCHIVAL_DPI ?= 200
ARCHIVAL_JPEG_QUALITY ?= 95

all: thesis.pdf abstract-en.pdf abstract-cs.pdf

# LaTeX must be run multiple times to get references right
thesis.pdf: thesis.tex $(wildcard *.tex) bibliography.bib $(eps) $(archival_papers)
	lualatex $<
	biber thesis
	lualatex $<
	lualatex $<

validate: thesis.pdf tools/validate-thesis.sh
	./tools/validate-thesis.sh $<

# Imported publisher PDFs contain fonts and colour objects that do not satisfy
# PDF/A-2u.  Render each page to a visually equivalent RGB archival facsimile;
# the original, searchable PDFs remain untouched in papers/.
papers/pdfa/%.pdf: papers/%.pdf pdfa.sh
	PDFA_DPI=$(ARCHIVAL_DPI) PDFA_JPEG_QUALITY=$(ARCHIVAL_JPEG_QUALITY) \
		./pdfa.sh $< $@

abstract-%.pdf: abstract-%.tex
	lualatex $<
	lualatex $<

img/%.eps: img/%.svg
	inkscape $< --export-type="eps" --export-filename=$@

clean:
	rm -f \
		*.aux \
		*.bbl \
        *.bcf \
		*.blg \
		*.dvi \
		*.fls \
		*.fdb_latexmk \
		*.synctex.gz \
		*.lof \
		*.log \
		*.lot \
		*.out \
        *.run.xml \
		*.toc \
        *.xmpdata \
		*.xmpi \
		;
	rm -f thesis.pdf abstract-en.pdf abstract-cs.pdf
	rm -f $(archival_papers)

.PHONY: all clean validate
