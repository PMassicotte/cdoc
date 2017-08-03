#!/bin/bash

pdftk figures.pdf burst output fig%02d.pdf
gs -sDEVICE=pngalpha -o fig%02d.png -r300 figures.pdf
