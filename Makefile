
all: thesis.pdf abstract-en.pdf abstract-cs.pdf

# LaTeX must be run multiple times to get references right
thesis.pdf: thesis.tex $(wildcard *.tex) refs.bib myrefs.bib thesis.xmpdata
	lualatex $<
	biber thesis
	lualatex $<
	lualatex $<

abstract-%.pdf: abstract-%.tex
	lualatex $<

clean:
	rm -f \
		*.aux \
		*.bbl \
		*.blg \
		*.dvi \
		*.fls \
		*.fdb_latexmk \
		*.synctex.gz \
		*.lof \
		*.log \
		*.lot \
		*.out \
		*.toc \
		*.xmpi \
		;
	rm -f thesis.pdf

.PHONY: all clean
