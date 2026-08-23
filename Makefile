#!/usr/bin/make -f

paper_sources = $(wildcard papers/*.pdf)
archival_papers = $(patsubst papers/%.pdf,papers/pdfa/%.pdf,$(paper_sources))
full_sources = $(wildcard sources/full/*.tex)
shared_sources = $(wildcard sources/shared/*.tex)
short_sources = $(wildcard sources/short/*.tex)
short_images = $(wildcard img/*.eps img/*.jpeg img/*.jpg img/*.pdf img/*.png)
reference_sources = $(wildcard references/*.bib)
thesis_sources = thesis.tex $(full_sources) $(shared_sources)
abstract_sources = $(shared_sources)

ARCHIVAL_DPI ?= 300
ARCHIVAL_COMPRESSION ?= Flate
CUNI_MAX_FILE_BYTES ?= 850000000

all: thesis.pdf abstract-en.pdf abstract-cs.pdf

short: thesis-short.pdf

publications: list-of-publications.pdf

# LaTeX must be run multiple times to get references right
thesis.pdf: $(thesis_sources) $(reference_sources) $(archival_papers)
	lualatex $<
	biber thesis
	lualatex $<
	lualatex $<

thesis-short.pdf: thesis-short.tex $(short_sources) $(shared_sources) $(reference_sources) $(short_images)
	lualatex $<
	biber thesis-short
	lualatex $<
	lualatex $<

list-of-publications.pdf: list-of-publications.tex thesis-short.tex $(shared_sources) $(reference_sources)
	lualatex $<
	biber list-of-publications
	lualatex $<
	lualatex $<

validate: thesis.pdf tools/validate-thesis.sh
	@file_size=$$(wc -c < $<); \
		if [ "$$file_size" -gt "$(CUNI_MAX_FILE_BYTES)" ]; then \
			echo "$< is $$file_size bytes; the MFF SIS limit is $(CUNI_MAX_FILE_BYTES) bytes." >&2; \
			exit 1; \
		fi
	./tools/validate-thesis.sh $<

validate-short: thesis-short.pdf tools/validate-thesis.sh
	@file_size=$$(wc -c < $<); \
		if [ "$$file_size" -gt "$(CUNI_MAX_FILE_BYTES)" ]; then \
			echo "$< is $$file_size bytes; the MFF SIS limit is $(CUNI_MAX_FILE_BYTES) bytes." >&2; \
			exit 1; \
		fi
	./tools/validate-thesis.sh $<

# Imported publisher PDFs contain fonts and colour objects that do not satisfy
# PDF/A-2u.  Render each page to a visually equivalent RGB archival facsimile;
# the original, searchable PDFs remain untouched in papers/.
papers/pdfa/%.pdf: papers/%.pdf tools/pdfa.sh
	PDFA_DPI=$(ARCHIVAL_DPI) PDFA_COMPRESSION=$(ARCHIVAL_COMPRESSION) \
		./tools/pdfa.sh $< $@

abstract-%.pdf: abstracts/abstract-%.tex $(abstract_sources)
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
	rm -f thesis.pdf abstract.pdf abstract-en.pdf abstract-cs.pdf pdfa-thesis.pdf thesis-core.pdf
	rm -f thesis-short.pdf
	rm -f list-of-publications.pdf
	rm -rf papers/pdfa validation

distclean: clean
	rm -rf .cache/cuni-thesis-validator

.PHONY: all short publications abstract clean distclean validate validate-short
