# Makefile
NAME = dot
VERSION = $(shell grep -m 1 -o '[0-9][0-9.]\+' README.md)

# Paths
PREFIX     ?= /usr/local
MANPREFIX  ?= $(PREFIX)/share/man
DOCDIR     ?= $(PREFIX)/share/doc/dot

INSTALLDIR := $(DESTDIR)$(PREFIX)
MANPREFIX  := $(DESTDIR)$(MANPREFIX)
DOCDIR     := $(DESTDIR)$(DOCDIR)

# Operatios
default: help

help:
	@echo 'Help message'
	@echo
	@echo 'make:            Do nothing and show help message.'
	@echo 'make options:    Show some options for installation.'
	@echo 'make install:    Install $(NAME).'
	@echo 'make uninstall:  Uninstall $(NAME).'
	@echo 'make man:        Compile the manpage with "pod2man".'

options:
	@echo 'Options'
	@echo
	@echo 'INSTALLDIR = $(INSTALLDIR)'
	@echo 'MANPREFIX = $(MANPREFIX)'
	@echo 'DOCDIR = $(DOCDIR)'

install:
	@echo 'Install $(NAME) ...'
	@echo
	install -d $(INSTALLDIR)/share/dot/
	install -d $(DOCDIR)
	install -m644 README.md README_ja.md LICENSE $(DOCDIR)
	cp -r examples $(INSTALLDIR)/share/dot/
	install -d $(MANPREFIX)/man1/
	install -m644 doc/dot.1 $(MANPREFIX)/man1/
	install -d $(INSTALLDIR)/bin
	install dot $(INSTALLDIR)/bin/dot

uninstall:
	rm -rf $(INSTALLDIR)/bin/dot $(INSTALLDIR)/share/luakit $(MANPREFIX)/man1/dot.1 $(DOCDIR)

man:
	pod2man --stderr -center='dot manual' --date='$(NAME)-$(VERSION)' \
	    --release=$(shell date +%x) doc/dot.pod doc/dot.1

.PHONY: default help options install uninstall man