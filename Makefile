TARGET?=systemd-homed
MODULES?=${TARGET:=.pp.bz2}
SHAREDIR?=/usr/share

all: ${TARGET:=.pp.bz2}

.PHONY: all clean install install-policy rpm

%.pp.bz2: %.pp
	@echo Compressing $^ -\> $@
	bzip2 -f -9 $^

%.pp: %.te
	make -f ${SHAREDIR}/selinux/devel/Makefile $@

clean:
	rm -f *~  *.tc *.pp *.pp.bz2
	rm -rf tmp .build *.tar.gz

install-policy: all
	semodule -i ${TARGET}.pp.bz2

install: all
	install -D -m 644 ${TARGET}.pp.bz2 ${DESTDIR}${SHAREDIR}/selinux/packages/${TARGET}.pp.bz2
	install -D -m 644 ${TARGET}.if ${DESTDIR}${SHAREDIR}/selinux/devel/include/contrib/${TARGET}.if

SRCDIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

rpm:
	rpmbuild \
		--define "_sourcedir $(SRCDIR)" \
		--define "_specdir $(SRCDIR)" \
		--define "_builddir $(SRCDIR)" \
		--define "_srcrpmdir $(SRCDIR)" \
		--define "_rpmdir $(SRCDIR)" \
		--define "_buildrootdir $(SRCDIR)/.build" \
		-ba ${TARGET}-selinux.spec
