################################################################################
# Makefile - Makefile for installing systemd-axia-alsa
################################################################################
#
# Copyright (C) 2017 Radio Bern RaBe
#                    Switzerland
#                    http://www.rabe.ch
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public 
# License as published  by the Free Software Foundation, version
# 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License  along with this program.
# If not, see <http://www.gnu.org/licenses/>.
#
# Please submit enhancements, bugfixes or comments via:
# https://github.com/radiorabe/systemd-axia-alsa
#
# Authors:
#  Christian Affolter <c.affolter@purplehaze.ch>

PN = systemd-axia-alsa

# Standard commands according to
# https://www.gnu.org/software/make/manual/html_node/Makefile-Conventions.html
SHELL = /bin/sh
INSTALL = /usr/bin/install
INSTALL_PROGRAM = $(INSTALL)
INSTALL_DATA = $(INSTALL) -m 644

# Standard directories according to
# https://www.gnu.org/software/make/manual/html_node/Directory-Variables.html#Directory-Variables
prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
datarootdir = $(prefix)/share
datadir = $(datarootdir)
docdir = $(datarootdir)/doc/$(PN)
sbindir = $(exec_prefix)/sbin
sysconfdir = $(prefix)/etc
libdir = $(exec_prefix)/lib

# Systemd directories
system_unitdir = $(exec_prefix)/systemd/system
user_unitdir = ${sysconfdir}/systemd/system
unitdir = ${user_unitdir}

# udev directories
system_udevdir = $(libdir)/udev
system_udevrulesdir = $(system_udevdir)/rules.d
user_udevdir = $(sysconfdir)/udev
user_udevrulesdir = $(user_udevdir)/rules.d
udevdir = $(system_udevdir)
udevrulesdir = $(user_udevrulesdir)

# Kernel auto module loading and configuration directories 
modulesloaddir = $(sysconfdir)/modules-load.d
modeprobedir = $(sysconfdir)/modprobe.d

# Axia configuration directory
axiaconfdir= ${sysconfdir}/axia


.PHONY: all
all:


.PHONY: installdirs
installdirs:
	$(INSTALL) -d $(DESTDIR)$(axiaconfdir) \
                  $(DESTDIR)$(docdir) \
                  $(DESTDIR)$(modeprobedir) \
                  $(DESTDIR)$(modulesloaddir) \
                  $(DESTDIR)$(udevdir) \
                  $(DESTDIR)$(udevrulesdir) \
                  $(DESTDIR)$(unitdir)


.PHONY: install
install: all installdirs
	$(INSTALL_DATA) systemd/*.service  $(DESTDIR)$(unitdir)/
	$(INSTALL_DATA) systemd/systemd-env.conf  $(DESTDIR)$(axiaconfdir)/
	$(INSTALL_PROGRAM) udev/snd-axia.sh $(DESTDIR)$(udevdir)/
	$(INSTALL_DATA) udev/90-snd-axia.rules $(DESTDIR)$(udevrulesdir)/
	$(INSTALL_DATA) modules-load.d/snd-axia.conf $(DESTDIR)$(modulesloaddir)/
	$(INSTALL_DATA) modprobe.d/snd-axia.conf $(DESTDIR)$(modeprobedir)/
	$(INSTALL_DATA) README.md $(DESTDIR)$(docdir)/
