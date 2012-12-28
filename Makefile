.PHONY: svg dir css

JADE_FILES=${wildcard *.jade}
COFFEE_FILES=${wildcard scripts/*.coffee}
CSS_FILES=${wildcard css/*.css}
SVG_FILES=${wildcard art/*.svg}

all: html js svg css

css: ${CSS_FILES}
	mkdir -p www/css
	cp -r css/* www/css/

html: ${JADE_FILES}
	jade --out www/ .


dir:
	mkdir -p www/js

js: ${COFFEE_FILES} dir
	toaster -d -c

svg:
	mkdir -p www/svg
	cp art/*.* www/svg/

serve: all
	cd www; python -m SimpleHTTPServer 8080