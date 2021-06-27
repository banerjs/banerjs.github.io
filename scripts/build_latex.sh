#!/bin/bash
# Build the latex files
set -ev

# Navigate to the pdf's directory
cd _pdf/

# For each `.tex` file, build it
# Nice to haves:
#   a) specify a pdflatex/xelatex build
#   b) specify .tex files to ignore
#   c) suppress certain warnings from commands
for texfile in *.tex; do
    filename=$(basename ${texfile} .tex)
    if [ ${filename} = "cv" ]; then
        echo "Skipping " ${filename}
        continue
    fi

    echo "Building " ${filename}
    xelatex ${filename}.tex
    bibtex ${filename}.aux || echo "Ignoring errors"
    xelatex ${filename}.tex
    xelatex ${filename}.tex
done
