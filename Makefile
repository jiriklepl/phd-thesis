#!/usr/bin/make -f

paper_sources = $(wildcard papers/*.pdf)
archival_papers = $(patsubst papers/%.pdf,papers/pdfa/%.pdf,$(paper_sources))
thesis_sources = \
	thesis.tex metadata.tex xmp.tex macros.tex title.tex \
	introduction.tex background.tex optimization-methods.tex abstractions.tex \
	llms.tex software.tex conclusion.tex bibliography.tex publications.tex \
	contributions.tex
abstract_sources = metadata.tex xmp.tex macros.tex

ARCHIVAL_DPI ?= 300
ARCHIVAL_COMPRESSION ?= Flate
CUNI_MAX_FILE_BYTES ?= 850000000

all: thesis.pdf abstract-en.pdf abstract-cs.pdf

# LaTeX must be run multiple times to get references right
thesis.pdf: $(thesis_sources) bibliography.bib $(archival_papers)
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

abstract-%.pdf: abstract-%.tex $(abstract_sources)
	lualatex $<
	lualatex $<

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
		*-SAVE-ERROR \
		.out \
		;
	rm -f thesis.pdf abstract-en.pdf abstract-cs.pdf pdfa-thesis.pdf thesis-core.pdf
	rm -rf papers/pdfa validation

distclean: clean
	rm -rf .cache/cuni-thesis-validator

.PHONY: all clean distclean validate
