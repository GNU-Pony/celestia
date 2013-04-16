# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.  [GNUAllPermissive]

ETC = /etc
VAR = /var
BIN = /sbin
PREFIX = /usr
PKGNAME = celestia
PY_SHEBANG = /usr/bin/env python
SPOOL = $(VAR)/spool/$(PKGNAME)
LIST = $(ETC)/$(PKGNAME)/list
COMMAND = celestia
LICENSES = $(PREFIX)/share/licenses

all: celestia

celestia: celestia.py
	sed -e 's:#!/usr/bin/env python:#!$(PY_SHEBANG):' < celestia.py > celestia
	chmod 755 celestia
	sed -i 's:$${SPOOL}:$(SPOOL):g' celestia
	sed -i 's:$${LIST}:$(LIST):g' celestia

install:
	install -dm755 '$(DESTDIR)'"$$(dirname '$(LIST)')"
	install -dm755 '$(DESTDIR)$(SPOOL)'
	touch '$(DESTDIR)/$(LIST)'
	install -dm755 '$(DESTDIR)$(LICENSES)/$(PKGNAME)'
	install -m644 COPYING LICENSE '$(DESTDIR)$(LICENSES)/$(PKGNAME)'
	install -dm755 '$(DESTDIR)$(PREFIX)$(BIN)'
	install -m755 celestia '$(DESTDIR)$(PREFIX)$(BIN)$(COMMAND)'

uninstall:
	rm -r '$(DESTDIR)$(SPOOL)'
	rm '$(DESTDIR)$(LIST)'
	rm '$(DESTDIR)$(LIST)~' || true
	rmdir "$$(dirname '$(DESTDIR)/$(LIST)')" || true
	rm '$(DESTDIR)$(LICENSES)/$(PKGNAME)/COPYING'
	rm '$(DESTDIR)$(LICENSES)/$(PKGNAME)/LICENSE'
	rmdir '$(DESTDIR)$(LICENSES)/$(PKGNAME)'
	rm '$(DESTDIR)$(PREFIX)$(BIN)/$(COMMAND)'

depends:
	@echo 'python>=3'

clean:
	rm celestia || true

