# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.  [GNUAllPermissive]

PY_SHEBANG = /usr/bin/env python
SPOOL = /var/spool/celestia
LIST = /etc/celestia/list

all: celestia

celestia: celestia.py
	sed -e 's:#!/usr/bin/env python:#!$(PY_SHEBANG):' < celestia.py > celestia
	chmod 755 celestia
	sed -i 's:$${SPOOL}:$(SPOOL):g' celestia
	sed -i 's:$${LIST}:$(LIST):g' celestia

install:
	install -dm755 "$$(dirname '$(LIST)')"
	install -dm755 '$(SPOOL)'
	touch '$(LIST)'

uninstall:
	rm -r '$(SPOOL)'
	rm '$(LIST)'
	rm '$(LIST)~' || true
	rmdir "$$(dirname '$(LIST)')" || true

clean:
	rm celestia || true

