# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.  [GNUAllPermissive]

ETC = /etc
VAR = /var
DEV = /dev
BIN = /sbin
DATA = /share
PREFIX = /usr
PKGNAME = celestia
PY_SHEBANG = /usr/bin/env python
SPOOL = $(VAR)/spool/$(PKGNAME)
LIST = $(ETC)/$(PKGNAME)/list
COMMAND = celestia
LICENSES = $(PREFIX)$(DATA)/licenses
LOCALPREFIX = /usr/local
LOCALSYSBIN = $(LOCALPREFIX)$(BIN)


.PHONY: all
all: doc bin


.PHONY: doc
doc: info

.PHONY: install
info: celestia.info.gz

%.info.gz: info/%.texinfo.install
	makeinfo "$<"
	gzip -9 -f "$*.info"

info/%.texinfo.install: info/%.texinfo
	cp "$<" "$@"
	sed -i 's:^@set SPOOL /var/spool/celestia:@set SPOOL $(SPOOL):g' "$@"
	sed -i 's:^@set LIST /etc/celestia/list:@set LIST $(LIST):g' "$@"
	sed -i 's:^@set DEVNULL /dev/null:@set DEVNULL $(DEV)/null:g' "$@"
	sed -i 's:^@set LOCALSYSBIN /usr/local/sbin:@set LOCALSYSBIN $(LOCALSYSBIN):g' "$@"


.PHONY: bin
bin: celestia

celestia: celestia.py
	sed -e "s:#!/usr/bin/env python:#!$(PY_SHEBANG):" < "$<" > "$@"
	chmod 755 "$@"
	sed -i 's:\$${SPOOL}:$(SPOOL):g' "$@"
	sed -i 's:\$${LIST}:$(LIST):g' "$@"


.PHONY: install
install:
	install -dm755 "$(DESTDIR)$$(dirname "$(LIST)")"
	install -dm755 "$(DESTDIR)$(SPOOL)"
	touch "$(DESTDIR)$(LIST)"
	install -dm755 "$(DESTDIR)$(LICENSES)/$(PKGNAME)"
	install -m644 COPYING LICENSE "$(DESTDIR)$(LICENSES)/$(PKGNAME)"
	install -dm755 "$(DESTDIR)$(PREFIX)$(BIN)"
	install -m755 celestia "$(DESTDIR)$(PREFIX)$(BIN)/$(COMMAND)"
	install -dm755 "$(DESTDIR)$(PREFIX)$(DATA)/info"
	install -m644 celestia.info.gz "$(DESTDIR)$(PREFIX)$(DATA)/info/$(PKGNAME).info.gz"

.PHONY: uninstall
uninstall:
	-rm -r -- "$(DESTDIR)$(SPOOL)"
	-rm -- "$(DESTDIR)$(LIST)"
	-rm -- "$(DESTDIR)$(LIST)~"
	-rm -d "$$(dirname "$(DESTDIR)$(LIST)")"
	-rm -- "$(DESTDIR)$(LICENSES)/$(PKGNAME)/COPYING"
	-rm -- "$(DESTDIR)$(LICENSES)/$(PKGNAME)/LICENSE"
	-rm -d -- "$(DESTDIR)$(LICENSES)/$(PKGNAME)"
	-rm -- "$(DESTDIR)$(PREFIX)$(BIN)/$(COMMAND)"
	-rm -- "$(DESTDIR)$(PREFIX)$(DATA)/info/$(PKGNAME).info.gz"

.PHONY: depends
depends:
	@echo "python>=3"
	@echo "bash"

.PHONY: clean
clean:
	-rm -f celestia {*,*/*}.{aux,cp,fn,info,ky,log,pdf,ps,dvi,pg,toc,tp,vr,install,gz}

