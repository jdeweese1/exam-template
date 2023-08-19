pdf: clean
	(rm example.pdf || true)
	(rm example_key.pdf || true)
	pandoc --pdf-engine pdflatex --template exam-template-key.tex  empty.md question_data.yml  --output example_key.pdf
	pandoc --pdf-engine pdflatex --template exam-template.tex  empty.md question_data.yml  --output example.pdf

install: clean
	wget https://github.com/jgm/pandoc/releases/download/3.1.6.1/pandoc-3.1.6.1-linux-amd64.tar.gz -O pandoc.tar.gz
	tar -xvzf pandoc.tar.gz --strip-components 1 -C ~/.local
	sudo yum install texlive
	wget  https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -O  texlive.tar.gz
	tar -xvzf texlive.tar.gz -C outdir

upload: pdf
	aws s3 cp example.pdf s3://jarod-public-s3/exams/example.pdf
	aws s3 cp example_key.pdf s3://jarod-public-s3/exams/example_key.pdf
	
	
clean:
	(rm *.pdf|| true)
	(rm *.tar.gz || true)

