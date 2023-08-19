pdf:
	(rm example.pdf || true)
	(rm example_key.pdf || true)
	pandoc --pdf-engine pdflatex --template exam-template-key.tex  empty.md question_data.yml  --output example_key.pdf
	pandoc --pdf-engine pdflatex --template exam-template.tex  empty.md question_data.yml  --output example.pdf
