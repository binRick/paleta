.POSIX:

PREFIX       = /usr/local
ALL_WARNINGS = -Wall -Wextra -pedantic -Wmissing-prototypes -Wstrict-prototypes
ALL_CFLAGS   = -std=c99 $(ALL_WARNINGS) -O3 $(CFLAGS) $(CPPFLAGS)

OBJ = src/paleta.o
HDR =

.c.o:
	$(CC) $(ALL_CFLAGS) -c -o $@ $<

paleta: $(OBJ)
	$(CC) $(ALL_CFLAGS) -o $@ $(OBJ) $(LDFLAGS)

$(OBJ): $(HDR)

install: paleta
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp paleta  $(DESTDIR)$(PREFIX)/bin/
	mkdir -p /etc/palettes
	[[ -d /etc/profile.d ]] && cp palette.sh /etc/profile.d
	rsync palettes/* /etc/palettes/.


clean:
	rm -f paleta $(OBJ)

.PHONY: install clean
