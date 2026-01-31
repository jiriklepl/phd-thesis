#!/usr/bin/make -f

eps = $(patsubst img/%.svg,img/%.eps,$(wildcard img/*.svg))

all: thesis.pdf abstract-en.pdf abstract-cs.pdf

# LaTeX must be run multiple times to get references right
thesis.pdf: thesis.tex $(wildcard *.tex) bibliography.bib $(eps)
	lualatex $<
	biber thesis
	lualatex $<
	lualatex $<

abstract-%.pdf: abstract-%.tex
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

.PHONY: all clean
