
# Simple LaTeX document generator skeleton.
# Fredrik Hederstierna 2026

SRC_TEX    = main
OUT_PATH   = out
BUILD_PATH = build
DST_PDF    = my_document
FLAGS      = -silent

# Download path of new PlantUML jar binary for diagram generation
PLANTUML_VERSION = 1.2026.8
PLANTUML_JAR = tools/plantuml.jar
PLANTUML_JAR_URL = https://github.com/plantuml/plantuml/releases/download/v$(PLANTUML_VERSION)/plantuml-$(PLANTUML_VERSION).jar

# PlantUML generates PNG file diagrams
DIAGRAMS_PUML_SRC := $(wildcard figures/*.puml)
DIAGRAMS_PNG := $(addsuffix .png, $(basename $(DIAGRAMS_PUML_SRC)))

# SVG inkscape generates PDF file diagrams
DIAGRAMS_SVG_SRC := $(wildcard figures/*.svg)
DIAGRAMS_PDF := $(addsuffix .pdf, $(basename $(DIAGRAMS_SVG_SRC)))

############################################################

all: $(DST_PDF).pdf
	@echo Created Document $(OUT_PATH)/$(DST_PDF).pdf.

# Main output document
$(DST_PDF).pdf: makefile $(DIAGRAMS_PNG) $(DIAGRAMS_PDF)
	@echo Generating $(DST_PDF)...
	latexmk $(FLAGS) -pdf -pdflatex="pdflatex -interaction=nonstopmode" -outdir=$(BUILD_PATH) $(SRC_TEX).tex
	@echo Copy generated doc to out dir
	@mkdir -p $(OUT_PATH)
	@cp $(BUILD_PATH)/$(SRC_TEX).pdf $(OUT_PATH)/$@

# If the JAR file isn't already present, download it
$(PLANTUML_JAR):
	mkdir -p tools
	curl -L --fail -o $@ $(PLANTUML_JAR_URL)

# Each PNG output depends on its corresponding .puml file
figures/%.png: figures/%.puml $(PLANTUML_JAR)
	java -jar $(PLANTUML_JAR) -tpng $^

# Each SVG output depends on its corresponding .svg file
figures/%.pdf: figures/%.svg
	inkscape $< --export-filename=$@

# Install needed packages to build document
# (run once before first build, pure user util function)
install_pkg:
#       # Install TexLive base
	sudo apt-get -y install texlive-latex-base
	sudo apt-get -y install latexmk
#       # Install some recommended and extra fonts
	sudo apt-get -y install texlive-latex-recommended
	sudo apt-get -y install texlive-fonts-recommended
	sudo apt-get -y install texlive-fonts-extra
#       # Install some extra packages
	sudo apt-get -y install texlive-latex-extra
	sudo apt-get -y install texlive-pictures
#       # To get 'bytefield.sty'
	sudo apt-get -y install texlive-science
#       # To get SVG generation
	sudo apt-get -y install inkscape
#       # Install everything (last resort if nothing else works)
#	# sudo apt-get -y install texlive-full

# Clean up compiled and generated files
clean:
#	rm -f *.aux *.log *.pdf *.out *.toc
#	rm -f $(OUT_PATH)/$(DST_PDF).pdf
	rm -fr $(BUILD_PATH)
	rm -fr $(OUT_PATH)
	rm -f $(DIAGRAMS_PNG) $(DIAGRAMS_PDF)
	@echo Keeping $(PLANTUML_JAR)

# Quirk of GNU Make: https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html
.PHONY: install_pkg clean all
