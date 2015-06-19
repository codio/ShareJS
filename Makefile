.PHONY: all test clean webclient

WEBPACK = node_modules/.bin/webpack

all: webclient

clean:
	rm -rf webclient/*

# Compile the types for a browser.
webclient:
	webpack -d --output-file share.js
	webpack -p --output-file share.min.js
