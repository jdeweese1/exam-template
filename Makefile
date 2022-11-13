pdf:
	pandoc --pdf-engine pdflatex --template exam-template.tex  empty.md question_data.yml  --output example.pdf
