#! /bin/bash

# appendix
# gs -dNOPAUSE -sFONTPATH=~/.fonts/typecatcher/ -dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -dEmbedAllFonts=true -sOutputFile=test.pdf -f appendix.pdf

# tables
gs -dNOPAUSE -sFONTPATH=~/.fonts/typecatcher/ -dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -dEmbedAllFonts=true -sOutputFile=article/tables/tables2.pdf -f article/tables/tables.pdf

mv article/tables/tables2.pdf article/tables/tables.pdf

# figures
gs -dNOPAUSE -sFONTPATH=~/.fonts/typecatcher/ -dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -dEmbedAllFonts=true -sOutputFile=article/figures/figures2.pdf -f article/figures/figures.pdf

mv article/figures/figures2.pdf article/figures/figures.pdf
