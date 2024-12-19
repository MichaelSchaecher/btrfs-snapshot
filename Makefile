#!/bin/env make -f

NAME = btrfs-snapshots-manager
VERSION = $(shell cat VERSION)

DESCRIPTION = A simple, but powerful way to manage btrfs snapshots on Ubuntu

BUILD_DIR = build/$(NAME)-$(VERSION)
DEBIAN_DIR = DEBIAN

SRC_DIR = src

APT_CONFIG_DIR = etc/apt/apt.conf.d

INSTALL_DIR = usr

BUILD_CHANGELOG = $(BUILD_DIR)/$(INSTALL_DIR)/share/doc/$(NAME)/changelog.DEBIAN

ROOT_DIR = $(shell pwd)

.PHONY: all install debian build

all: build install

build:

	@mkdir -pv $(BUILD_DIR)/$(INSTALL_DIR)/bin \
		$(BUILD_DIR)/$(INSTALL_DIR)/share/doc/$(NAME) \
		$(BUILD_DIR)/$(INSTALL_DIR)/lib/systemd/system \
		$(BUILD_DIR)/$(APT_CONFIG_DIR)

	@cp -vf $(SRC_DIR)/$(NAME) $(BUILD_DIR)/$(INSTALL_DIR)/bin/
	@cp -vf $(SRC_DIR)/$(NAME).conf $(BUILD_DIR)/etc

	@cp -vf $(SRC_DIR)/$(NAME).service $(BUILD_DIR)/$(INSTALL_DIR)/lib/systemd/system/
	@cp -vf $(SRC_DIR)/$(NAME).timer $(BUILD_DIR)/$(INSTALL_DIR)/lib/systemd/system/

	@cp -vf $(SRC_DIR)/$(NAME).conf $(BUILD_DIR)/etc/
	@cp -vf $(SRC_DIR)/50_$(NAME) $(BUILD_DIR)/$(APT_CONFIG_DIR)/

	@cp -vf ./COPYING $(BUILD_DIR)/$(INSTALL_DIR)/share/doc/$(NAME)/copyright
	@cp -vf ./VERSION $(BUILD_DIR)/$(INSTALL_DIR)/share/doc/$(NAME)/version

ifeq ($(MANPAGE),y)
	@mkdir -pv $(BUILD_DIR)/$(INSTALL_DIR)/share/man/man8
	@pandoc -s -t man $(SRC_DIR)/$(NAME).8.md -o $(BUILD_DIR)/$(INSTALL_DIR)/share/man/man8/$(NAME).8
	@gzip --best -nvf $(BUILD_DIR)/$(INSTALL_DIR)/share/man/man8/$(NAME).8
endif

	@chmod -v 0755 $(BUILD_DIR)/$(INSTALL_DIR)/bin/$(NAME)
	@chmod -v 0644 $(BUILD_DIR)/$(INSTALL_DIR)/lib/systemd/system/ \
		$(BUILD_DIR)/$(APT_CONFIG_DIR)/ \
		$(BUILD_DIR)/etc/ \
		$(BUILD_DIR)/$(INSTALL_DIR)/share/doc/$(NAME)/

ifeq ($(DEBIAN),y)
	@mkdir -pv $(BUILD_DIR)/$(DEBIAN_DIR)
	@cp -vf $(SRC_DIR)/debian/control $(BUILD_DIR)/$(DEBIAN_DIR)/
	@cp -vf $(SRC_DIR)/debian/postinst $(BUILD_DIR)/$(DEBIAN_DIR)/

	@sed -i "s/Version:/Version: $(VERSION)/" $(BUILD_DIR)/$(DEBIAN_DIR)/control

	@chmod -v 0755 $(BUILD_DIR)/$(DEBIAN_DIR)/postinst

endif

clean:

	@rm -Rvf $(BUILD_DIR)

