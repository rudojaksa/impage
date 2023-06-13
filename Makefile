T    := impage
PATH := $(PATH):UTIL
SHELL := /bin/bash
TMP   := /tmp/build-impage
SRC  := $(T:%=%.pl)

all: web.pl $T

$T: $T.pl *.pl */*.pl | CONFIG.pl
	perlpp $< > $@
	@chmod 755 $@

CONFIG.pl: $(SRC) Makefile
	@mkversionpl | grep -v MAKE > $@.bkp
	@if diffversionpl $@ $@.bkp; then echo "update $@"; mv $@.bkp $@; else rm -f $@.bkp; fi

# web
web.pl: $(TMP)/web.html $(TMP)/web.css $(TMP)/web.js | $(TMP)
	@echo > $(TMP)/empty
	echo -e "# do not edit! auto-generated from: $(+:$(TMP)/%=web/%)\n" > $(TMP)/hdr
	cat $(TMP)/hdr > $@
	cat $(TMP)/web.js $(TMP)/empty >> $@
	cat $(TMP)/web.css $(TMP)/empty >> $@
	cat $(TMP)/web.html $(TMP)/empty >> $@

# first remove comments, then remove empty lines
$(TMP)/web.css: web/web.css Makefile | $(TMP)
	echo -e "our \$$CSS=<<EOF;\n`cat $< | sed 's:/\*.*\*/::g'`\nEOF" > $@.tmp
	@sed /^$$/d $@.tmp > $@
$(TMP)/web.js: web/web.js Makefile | $(TMP)
	echo -e "our \$$JAVASCRIPT=<<EOF;\n`cat $< | sed 's:/\*.*\*/::g'`\nEOF" > $@.tmp
	@sed /^$$/d $@.tmp > $@
$(TMP)/web.html: web/web.html Makefile | $(TMP)
	echo -e "our \$$HTML=<<EOF;\n`cat $<`\nEOF" > $@.tmp
	@sed /^$$/d $@.tmp > $@

$(TMP):
	mkdir -p $@

clean:
	rm -rf $(TMP)
	rm -f web.pl
	rm -f $T

-include ~/.gitlab/Makefile.git

