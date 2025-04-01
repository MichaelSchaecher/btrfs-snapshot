#!/bin/env make -f

PACKAGE = $(shell basename $(shell pwd))
VERSION = $(shell bash scripts/set-version)-testing

MAINTAINER = $(shell git config user.name) <$(shell git config user.email)>

INSTALL = btrfs-progs, bash (>= 4.4)
BUILD = debhelper (>= 11), git, make (>= 4.1), dpkg-dev

HOMEPAGE = https://github.com/MichaelSchaecher/ddns

ARCH = $(shell dpkg --print-architecture)

PACKAGE_DIR = package

WORKING_DIR = $(shell pwd)

DESCRIPTION = Manage BTRFS snapshots simply -
LONG_DESCRIPTION = Maintain snapshots of on BTRFS filesystems configured \
	the proper way.

export PACKAGE VERSION MAINTAINER INSTALL BUILD HOMEPAGE ARCH PACKAGE_DIR WORKING_DIR DESCRIPTION LONG_DESCRIPTION

# Phony targets
.PHONY: all debian clean help

# Default target
all: debian

debian:

	@echo "Building package $(PACKAGE) version $(VERSION)"

	@echo "$(VERSION)" > $(PACKAGE_DIR)/usr/share/doc/$(PACKAGE)/version

ifeq ($(MANPAGE),yes)
	@pandoc -s -t man man/$(PACKAGE).8.md -o \
		$(PACKAGE_DIR)/usr/share/man/man8/$(PACKAGE).8
	@gzip --best -nvf $(PACKAGE_DIR)/usr/share/man/man8/$(PACKAGE).8
endif

	@dpkg-changelog $(PACKAGE_DIR)/DEBIAN/changelog
	@dpkg-changelog $(PACKAGE_DIR)/usr/share/doc/$(PACKAGE)/changelog
	@gzip -d $(PACKAGE_DIR)/DEBIAN/*.gz
	@mv $(PACKAGE_DIR)/DEBIAN/changelog.DEBIAN $(PACKAGE_DIR)/DEBIAN/changelog

	@scripts/set-control
	@scripts/gen-chsums

ifeq ($(FORCE_DEB),yes)
	@scripts/mkdeb --force
else
	@scripts/mkdeb
endif

install:

	@dpkg -i $(PACKAGE)_$(VERSION)_$(ARCH).deb

clean:
	@rm -vf $(PACKAGE_DIR)/DEBIAN/control \
		$(PACKAGE_DIR)/DEBIAN/changelog \
		$(PACKAGE_DIR)/DEBIAN/md5sums \
		$(PACKAGE_DIR)/usr/share/doc/$(PACKAGE)/*.gz \
		$(PACKAGE_DIR)/usr/share/man/man8/$(PACKAGE).8.gz \

help:
	@echo "Usage: make [target] <variables>"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build the debian package and install it"
	@echo "  debian    - Build the debian package"
	@echo "  install   - Install the debian package"
	@echo "  clean     - Clean up build files"
	@echo "  help      - Display this help message"
	@echo ""
