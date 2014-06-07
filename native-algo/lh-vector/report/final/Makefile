
all: report.tex
	pdflatex report.tex
	bibtex report
	pdflatex report.tex
	pdflatex report.tex

clean:
	-rm -rf *.dvi *.log *.dvi *.aux *.gz *.out *.pdf *.bbl *.blg *.pre