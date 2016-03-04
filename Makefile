all:
	pandoc -s slides.md -t revealjs -o index.html --self-contained -V theme=solarized
