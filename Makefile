ifeq ($(BASE_FILE_NAME),)
	BASE_FILE_NAME := example
endif


help:
	cat Makefile | grep -e '\S:[[:space:]]'

pdf: clean
	(rm $(BASE_FILE_NAME).pdf || true)
	(rm $(BASE_FILE_NAME)_key.pdf || true)
	pandoc --pdf-engine pdflatex --template exam-template-key.tex  empty.md question_data.yml  --output $(BASE_FILE_NAME)_key.pdf
	pandoc --pdf-engine pdflatex --template exam-template.tex  empty.md question_data.yml  --output $(BASE_FILE_NAME).pdf

install: clean
	wget https://github.com/jgm/pandoc/releases/download/3.1.6.1/pandoc-3.1.6.1-linux-amd64.tar.gz -O pandoc.tar.gz
	tar -xvzf pandoc.tar.gz --strip-components 1 -C ~/.local
	sudo yum install texlive
	wget  https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz -O  texlive.tar.gz
	tar -xvzf texlive.tar.gz -C outdir

upload:
	aws s3 cp $(BASE_FILE_NAME).pdf s3://jarod-public-s3/exams/$(BASE_FILE_NAME).pdf
	aws s3 presign s3://jarod-public-s3/exams/$(BASE_FILE_NAME).pdf --expires-in 604800
	aws s3 cp $(BASE_FILE_NAME)_key.pdf s3://jarod-public-s3/exams/$(BASE_FILE_NAME)_key.pdf
	aws s3 presign s3://jarod-public-s3/exams/$(BASE_FILE_NAME)_key.pdf

upload-study-%: export QUESTION_TYPE=$*
upload-study-%:
	aws s3 cp  duolingo_$(QUESTION_TYPE)_import.txt s3://jarod-public-s3/study/duolingo_$(QUESTION_TYPE)s_import.txt
	
spanish-quizlet-%:  export QUESTION_TYPE=$*
spanish-quizlet-%:
	cat data/spanish_$(QUESTION_TYPE).json |jq 'to_entries'  |in2csv -f json |csvformat -T -Q🐍> duolingo_$(QUESTION_TYPE)_import.txt



spanish-%: export QUESTION_TYPE=$*
spanish-%: export B64_ENV_QUESTIONS=$(shell python3 question_transformer.py $(QUESTION_TYPE)|base64 -w0)
spanish-%: export BASE_FILE_NAME=span_questions_$(QUESTION_TYPE)
spanish-%: clean
	echo "$(QUESTION_TYPE)"
	./populate_template.sh
	(rm example.pdf || true)
	(rm example_key.pdf || true)
	pandoc --pdf-engine pdflatex --template exam-template-key.tex  empty.md $(BASE_FILE_NAME).yml  --output $(BASE_FILE_NAME)_key.pdf
	pandoc --pdf-engine pdflatex --template exam-template.tex  empty.md $(BASE_FILE_NAME).yml  --output $(BASE_FILE_NAME).pdf
	$(MAKE) upload
	
	
clean:
	(rm *.pdf|| true)
	(rm *.tar.gz || true)
	(rm *.yml || true)

