#!/usr/bin/make -f

eps = $(patsubst img/%.svg,img/%.eps,$(wildcard img/*.svg))
paper_sources = $(wildcard papers/*.pdf)
archival_papers = $(patsubst papers/%.pdf,papers/pdfa/%.pdf,$(paper_sources))

ARCHIVAL_DPI ?= 300
ARCHIVAL_COMPRESSION ?= Flate
CUNI_MAX_FILE_BYTES ?= 850000000

all: thesis.pdf abstract-en.pdf abstract-cs.pdf

# LaTeX must be run multiple times to get references right
thesis.pdf: thesis.tex $(wildcard *.tex) bibliography.bib $(eps) $(archival_papers)
	lualatex $<
	biber thesis
	lualatex $<
	lualatex $<

validate: thesis.pdf tools/validate-thesis.sh
	@file_size=$$(wc -c < $<); \
		if [ "$$file_size" -gt "$(CUNI_MAX_FILE_BYTES)" ]; then \
			echo "$< is $$file_size bytes; the MFF SIS limit is $(CUNI_MAX_FILE_BYTES) bytes." >&2; \
			exit 1; \
		fi
	./tools/validate-thesis.sh $<

# Imported publisher PDFs contain fonts and colour objects that do not satisfy
# PDF/A-2u.  Render each page to a visually equivalent RGB archival facsimile;
# the original, searchable PDFs remain untouched in papers/.
papers/pdfa/%.pdf: papers/%.pdf pdfa.sh
	PDFA_DPI=$(ARCHIVAL_DPI) PDFA_COMPRESSION=$(ARCHIVAL_COMPRESSION) \
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
